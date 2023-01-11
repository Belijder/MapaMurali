//
//  AddNewViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import AVFoundation
import CoreLocation

class AddNewItemViewController: MMDataLoadingVC {
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var vm = AddNewViewModel()

    var databaseManager: DatabaseManager
    
    let selectedImageView = MMMuralImageView(frame: .zero)
    let removeImageButton = MMCircleButton(color: .label, systemImageName: "xmark")
    let adressTextField = MMTextField(placeholder: "Wpisz adres muralu", type: .custom)
    let cityTextField = MMTextField(placeholder: "Miasto", type: .custom)
    let authorTextField = MMTextField(placeholder: "Jeśli znasz, podaj autorów.", type: .custom)
    let callToActionBatton = MMTintedButton(color: MMColors.primary, title: "Dodaj mural")
    
    var selectedImageViewWidthConstraint: NSLayoutConstraint!
    var selectedImageViewHeightConstraint: NSLayoutConstraint!
    var removeImageButtonHeightConstraint: NSLayoutConstraint!
    var removeImageButtonWidthConstraint: NSLayoutConstraint!
    
    var selectedImageViewTopAnchorConstant: CGFloat = 80
    
    
    //MARK: - Inicialization
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(selectedImageView, removeImageButton, adressTextField, cityTextField, authorTextField, callToActionBatton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configureRemoveImageButton()
        configureCameraImageView()
        configureCallToActionButton()
        configureTextFields()
        
        locationManager.delegate = self
        databaseManager.delegate = self
        
        layoutUI()
        createDissmisKeyboardTapGesture()
    }
    
 
    override func viewDidLayoutSubviews() {
        adressTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
        cityTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
        authorTextField.styleTextFieldWithBottomBorder(color: MMColors.primary)
    }
    
    //MARK: - Set up
    private func configureRemoveImageButton() {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15)
        removeImageButton.configuration?.preferredSymbolConfigurationForImage = symbolConfiguration
        removeImageButton.alpha = 0.0
        removeImageButton.addTarget(self, action: #selector(removeImageButtonTapped), for: .touchUpInside)
    }
    
    
    private func configureCameraImageView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cameraImageViewTapped))
        selectedImageView.isUserInteractionEnabled = true
        selectedImageView.addGestureRecognizer(tap)
    }
    
    
    private func configureCallToActionButton() {
        callToActionBatton.addTarget(self, action: #selector(callToActionButtonTapped), for: .touchUpInside)
    }
    
    
    private func configureTextFields() {
        adressTextField.delegate = self
        adressTextField.tag = 1
        adressTextField.returnKeyType = .next
        
        let localizationButton = MMCircleButton(color: MMColors.primary, systemImageName: "location.circle.fill")
        localizationButton.frame = CGRect(x: adressTextField.frame.size.width - 25, y: 25, width: 25, height: 25)
        adressTextField.rightView = localizationButton
        adressTextField.rightViewMode = .always
        localizationButton.addTarget(self, action: #selector(localizationButtonTapped), for: .touchUpInside)
        
        cityTextField.delegate = self
        cityTextField.tag = 2
        cityTextField.returnKeyType = .next
        
        authorTextField.delegate = self
        authorTextField.tag = 3
        authorTextField.returnKeyType = .done
    }
    
    
    private func layoutUI() {
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 15
        let height: CGFloat = 45
        
        selectedImageViewWidthConstraint = selectedImageView.widthAnchor.constraint(equalToConstant: 300)
        selectedImageViewWidthConstraint.isActive = true
        
        selectedImageViewHeightConstraint = selectedImageView.heightAnchor.constraint(equalToConstant: 400)
        selectedImageViewHeightConstraint.isActive = true
        
        removeImageButtonWidthConstraint = removeImageButton.heightAnchor.constraint(equalToConstant: 40)
        removeImageButtonWidthConstraint.isActive = true
        removeImageButtonHeightConstraint = removeImageButton.widthAnchor.constraint(equalToConstant: 40)
        removeImageButtonHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: selectedImageViewTopAnchorConstant),
            
            removeImageButton.topAnchor.constraint(equalTo: selectedImageView.topAnchor, constant: 10),
            removeImageButton.trailingAnchor.constraint(equalTo: selectedImageView.trailingAnchor, constant: -10),
            
            adressTextField.topAnchor.constraint(equalTo: selectedImageView.bottomAnchor, constant: verticalPadding + 10),
            adressTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            adressTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            adressTextField.heightAnchor.constraint(equalToConstant: height),
            
            cityTextField.topAnchor.constraint(equalTo: adressTextField.bottomAnchor, constant: verticalPadding),
            cityTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            cityTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            cityTextField.heightAnchor.constraint(equalToConstant: height),
            
            authorTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: verticalPadding),
            authorTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            authorTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            authorTextField.heightAnchor.constraint(equalToConstant: height),
            
            callToActionBatton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            callToActionBatton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            callToActionBatton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding),
            callToActionBatton.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    //MARK: - Logic
    
    func createDissmisKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func cleanUpFields() {
        selectedImageView.removeImage()
        adressTextField.text = ""
        cityTextField.text = ""
        authorTextField.text = ""
        removeImageButton.alpha = 0
    }
    
    //MARK: - Actions
    
    @objc func cameraImageViewTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Zrób zdjęcie", style: .default) { _ in self.actionSheetCameraButtonTapped() })
        actionSheet.addAction(UIAlertAction(title: "Wybierz z galerii", style: .default) { _ in self.actionSheetLibraryButtonTapped() })
        actionSheet.addAction(UIAlertAction(title: "Wróć", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    func actionSheetCameraButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showLoadingView(message: "Uzyskiwanie dostępu do aparatu...")
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true)
        }
    }
    
    func actionSheetLibraryButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            showLoadingView(message: "Otwieranie albumu ze zdjęciami...")
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
        }
    }
    
    @objc func removeImageButtonTapped() {
        selectedImageView.removeImage()
        removeImageButton.alpha = 0.0
    }
    
    @objc func localizationButtonTapped() {
        locationManager.requestLocation()
        showLoadingView(message: "Pobieranie lokalizacji...")
    }
    
    @objc func callToActionButtonTapped() {
        
        guard let fullSizeImageData = self.vm.fullSizeImageData, let thumbnailImageData = self.vm.thumbnailImageData else {
            self.presentMMAlert(title: "Nie można załadować zdjęcia.", message: "Wybierz lub zrób inne zdjęcie i spróbuj ponownie.", buttonTitle: "Ok")
            return
        }
        
        vm.adress = adressTextField.text
        vm.city = cityTextField.text
        
        guard let adress = vm.adress, let city = vm.city else {
            self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.invalidAddress.rawValue, buttonTitle: "Ok")
            return
        }
        
        let addressString = "\(adress), \(city)"
        
        vm.getCoordinate(addressString: addressString) { location, error in
            if error != nil {
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.invalidAddress.rawValue, buttonTitle: "Ok")
                return
            }
            
            do {
                let data = try self.vm.createDataforDatabase(author: self.authorTextField.text, location: location)
                self.showLoadingView(message: "Dodawanie muralu...")
                self.databaseManager.addNewItemToDatabase(itemData: data, fullSizeImageData: fullSizeImageData, thumbnailData: thumbnailImageData)
            } catch let error {
                self.presentMMAlert(title: "Mural nie został dodany", message: error.localizedDescription, buttonTitle: "Ok")
            }
        }
    }


    //MARK: - Biding
    @objc func keyboardWillShow(notification: Notification) {
        self.keyboardAnimationControl(notification, keyboardIsShowing: true)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.keyboardAnimationControl(notification, keyboardIsShowing: false)
    }
    
    private func keyboardAnimationControl(_ notification: Notification, keyboardIsShowing: Bool) {
        let userInfo = notification.userInfo!
        let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value
        let options = UIView.AnimationOptions(rawValue: UInt(curve!) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        if keyboardIsShowing {
            self.selectedImageViewWidthConstraint.constant = 180
            self.selectedImageViewHeightConstraint.constant = 245
            
            self.removeImageButtonWidthConstraint.constant = 22
            self.removeImageButtonHeightConstraint.constant = 22
            
            let removeButtonConfig = UIImage.SymbolConfiguration(pointSize: 10)
            self.removeImageButton.configuration?.preferredSymbolConfigurationForImage = removeButtonConfig
            
            var cameraImageConfig = UIImage.SymbolConfiguration(paletteColors: [.secondaryLabel])
            cameraImageConfig = cameraImageConfig.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40.0)))
            self.selectedImageView.placeholderView.cameraImage.preferredSymbolConfiguration = cameraImageConfig
            
        } else {
            self.selectedImageViewWidthConstraint.constant = 300
            self.selectedImageViewHeightConstraint.constant = 400
            
            self.removeImageButtonWidthConstraint.constant = 44
            self.removeImageButtonHeightConstraint.constant = 44
            
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15)
            self.removeImageButton.configuration?.preferredSymbolConfigurationForImage = symbolConfiguration
            
            var cameraImageConfig = UIImage.SymbolConfiguration(paletteColors: [.secondaryLabel])
            cameraImageConfig = cameraImageConfig.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 80.0)))
            self.selectedImageView.placeholderView.cameraImage.preferredSymbolConfiguration = cameraImageConfig
        }
        
        UIView.animate(
            withDuration: duration!,
            delay: 0,
            options: options,
            animations: { self.view.layoutIfNeeded() }
        )
    }
}

//MARK: - Extensions
extension AddNewItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismissLoadingView()
        
        var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        if let imageToCheck = image {
            if imageToCheck.size.width > imageToCheck.size.height {
                let verticalImage = imageToCheck.cropImageToVerticalRectangle()
                image = verticalImage
            }
        }
        
        let compressedImage = image?.jpegData(compressionQuality: 0.3)
        
        selectedImageView.image = UIImage(data: compressedImage!)
        
        self.vm.fullSizeImageData = compressedImage
        
        let resizedImage = image?.aspectFittedToHeight(133)
        
        let thumbnailData = resizedImage?.jpegData(compressionQuality: 0.3)
        self.vm.thumbnailImageData = thumbnailData

        selectedImageView.didSelectedImage()
        removeImageButton.alpha = 1.0
        
        self.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("🟡 Cancel button tapped in UIImagePickerController")
        dismiss(animated: true, completion: nil)
        self.dismissLoadingView()
    }
}

extension AddNewItemViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

extension AddNewItemViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last?.coordinate else {
            self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.locationRetrivalFaild.rawValue, buttonTitle: "Ok")
            return
        }
        
        self.vm.currentLocation = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
        
        guard let location = vm.currentLocation else {
            self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.locationRetrivalFaild.rawValue, buttonTitle: "Ok")
            return
        }
        
        self.geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placeMark = placemarks?.first,
                  let streetName = placeMark.thoroughfare,
                  let streetNumber = placeMark.subThoroughfare,
                  let cityName = placeMark.locality else {
                self.dismissLoadingView()
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.locationRetrivalFaild.rawValue, buttonTitle: "Ok")
                return
            }
            
            self.adressTextField.text = "\(streetName) \(streetNumber)"
            self.cityTextField.text = cityName
            self.vm.adress = "\(streetName) \(streetNumber)"
            self.vm.city = cityName
            self.dismissLoadingView()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension AddNewItemViewController: DatabaseManagerDelegate {
    func failedToEditMuralData(errorMessage: String) {
        dismissLoadingView()
        self.presentMMAlert(title: "Nie udało się zaktualizować danych.", message: errorMessage, buttonTitle: "Ok")
    }
    
    func successToEditMuralData(muralID: String, data: EditedDataForMural) {
        if let index = databaseManager.murals.firstIndex(where: { $0.docRef == muralID }) {
            
            var mural = databaseManager.murals[index]
            mural.longitude = data.location.longitude
            mural.latitude = data.location.latitude
            mural.author = data.author
            mural.city = data.city
            mural.adress = data.address
            
            databaseManager.lastEditedMuralID.onNext(mural)
        }
        
        dismissLoadingView()
        self.dismiss(animated: true)
    }
    
    func successToAddNewItem(muralID: String) {
        dismissLoadingView()
        self.databaseManager.fetchMuralfromDatabase(with: muralID)
        self.presentMMAlert(title: "Udało się!", message: "Twój mural został dodany! Dzięki za pomoc w tworzeniu naszej mapy!", buttonTitle: "Ok")
        self.cleanUpFields()

    }
    
    func failedToAddNewItem(errortitle: String, errorMessage: String) {
        dismissLoadingView()
        self.presentMMAlert(title: errortitle, message: errorMessage, buttonTitle: "Ok")
    }

}
