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
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var currentLocation: CLLocation?
    
    let selectedImageView = MMMuralImageView(frame: .zero)
    let removeImageButton = MMCircleButton(color: .label, systemImageName: "xmark")
    let adressTextField = MMTextField(placeholder: "Wpisz adres muralu", type: .custom)
    let cityTextField = MMTextField(placeholder: "Miasto", type: .custom)
    let authorTextField = MMTextField(placeholder: "Jeśli znasz, podaj autorów.", type: .custom)
    let callToActionBatton = MMTintedButton(color: .systemGreen, title: "Dodaj mural")
    
    var selectedImageViewWidthConstraint: NSLayoutConstraint!
    var selectedImageViewHeightConstraint: NSLayoutConstraint!
    var removeImageButtonHeightConstraint: NSLayoutConstraint!
    var removeImageButtonWidthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(selectedImageView, removeImageButton, adressTextField, cityTextField, authorTextField, callToActionBatton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configureRemoveImageButton()
        configureCameraImageView()
        configureCallToActionButton()
        adressTextField.delegate = self
        cityTextField.delegate = self
        authorTextField.delegate = self
        locationManager.delegate = self
        layoutUI()
        configureAdressTextField()
        createDissmisKeyboardTapGesture()
        
    }
    
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
 
    override func viewDidLayoutSubviews() {
        adressTextField.styleTextFieldWithBottomBorder(color: .systemGreen)
        cityTextField.styleTextFieldWithBottomBorder(color: .systemGreen)
        authorTextField.styleTextFieldWithBottomBorder(color: .systemGreen)
    }
    
    private func configureRemoveImageButton() {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15)
        removeImageButton.configuration?.preferredSymbolConfigurationForImage = symbolConfiguration
        removeImageButton.alpha = 0.0
        removeImageButton.addTarget(self, action: #selector(removeImageButtonTapped), for: .touchUpInside)
    }
    
    @objc func removeImageButtonTapped() {
        selectedImageView.removeImage()
        removeImageButton.alpha = 0.0
    }
    
    private func configureCameraImageView() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cameraImageViewTapped))
        selectedImageView.isUserInteractionEnabled = true
        selectedImageView.addGestureRecognizer(tap)
    }
    
    @objc func cameraImageViewTapped() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Zrób zdjęcie", style: .default) { _ in self.actionSheetCameraButtonTapped() })
        ac.addAction(UIAlertAction(title: "Wybierz z galerii", style: .default) { _ in self.actionSheetLibraryButtonTapped() })
        ac.addAction(UIAlertAction(title: "Wróć", style: .cancel))
        present(ac, animated: true)
    }
    
    func actionSheetCameraButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true)
        }
    }
    
    func actionSheetLibraryButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
        }
    }
    
    
    func configureAdressTextField() {
        let localizationButton = MMCircleButton(color: .systemGreen, systemImageName: "location.circle.fill")
        localizationButton.frame = CGRect(x: adressTextField.frame.size.width - 25, y: 25, width: 25, height: 25)
        adressTextField.rightView = localizationButton
        adressTextField.rightViewMode = .always
        localizationButton.addTarget(self, action: #selector(localizationButtonTapped), for: .touchUpInside)
        
    }
    
    @objc func localizationButtonTapped() {
        locationManager.requestLocation()
        showLoadingView()
    }
    
    private func configureCallToActionButton() {
        callToActionBatton.addTarget(self, action: #selector(callToActionButtonTapped), for: .touchUpInside)
    }
    
    @objc func callToActionButtonTapped() {
        geoCoder.geocodeAddressString(adressTextField.text!) { placemark, error in
            
            guard error == nil, let coordinates = placemark![0].location?.coordinate else {
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.locationRetrivalFaild.rawValue, buttonTitle: "Ok")
                return
            }
            print(coordinates)
            
//            self.presentMMAlert(title: "Udało się!", message: "Twój mural został dodany! Dzięki!", buttonTitle: "Ok")
        }
    }
    
    func createDissmisKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
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
            selectedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            
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
}

extension AddNewItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let compressedImage = image?.jpegData(compressionQuality: 0.3)
        
        selectedImageView.image = UIImage(data: compressedImage!)
        
        print("Compressed image: \(compressedImage)")
        
        let resizedImage = image?.aspectFittedToHeight(70)
        let thumbnailData = resizedImage?.jpegData(compressionQuality: 0.1)
        print("Resized image: \(thumbnailData)")
        
        
        selectedImageView.didSelectedImage()
        removeImageButton.alpha = 1.0
        
        self.dismiss(animated: true)
    }
}

extension AddNewItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddNewItemViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last?.coordinate else {
            self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.locationRetrivalFaild.rawValue, buttonTitle: "Ok")
            return
        }
        
        self.currentLocation = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
        
        guard let location = currentLocation else {
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
            self.cityTextField.text = "\(cityName)"
            self.dismissLoadingView()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
