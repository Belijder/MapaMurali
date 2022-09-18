//
//  AddNewViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import AVFoundation
import CoreLocation

class AddNewItemViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    let selectedImageView = MMMuralImageView(frame: .zero)
    let removeImageButton = MMCircleButton(color: .label, systemImageName: "xmark")
    let adressTextField = MMTextField(placeholder: "Wpisz adres muralu", type: .custom)
    let authorTextField = MMTextField(placeholder: "Jeśli znasz, podaj autorów.", type: .custom)
    let callToActionBatton = MMTintedButton(color: .systemGreen, title: "Dodaj mural")


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubViews(selectedImageView, removeImageButton, adressTextField, authorTextField, callToActionBatton)
        configureRemoveImageButton()
        configureCameraImageView()
        adressTextField.delegate = self
        authorTextField.delegate = self
        locationManager.delegate = self
        layoutUI()
        configureAdressTextField()
        createDissmisKeyboardTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        adressTextField.styleTextFieldWithBottomBorder(color: .systemGreen)
        authorTextField.styleTextFieldWithBottomBorder(color: .systemGreen)
    }
    
    private func configureRemoveImageButton() {
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
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
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
    }
    
    func createDissmisKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    private func layoutUI() {
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20
        let height: CGFloat = 50
        
        NSLayoutConstraint.activate([
            selectedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedImageView.heightAnchor.constraint(equalToConstant: 400),
            selectedImageView.widthAnchor.constraint(equalToConstant: 300),
            
            removeImageButton.topAnchor.constraint(equalTo: selectedImageView.topAnchor, constant: 10),
            removeImageButton.trailingAnchor.constraint(equalTo: selectedImageView.trailingAnchor, constant: -10),
            removeImageButton.heightAnchor.constraint(equalToConstant: 44),
            removeImageButton.widthAnchor.constraint(equalToConstant: 44),
            
            adressTextField.topAnchor.constraint(equalTo: selectedImageView.bottomAnchor, constant: padding),
            adressTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            adressTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            adressTextField.heightAnchor.constraint(equalToConstant: height),
            
            authorTextField.topAnchor.constraint(equalTo: adressTextField.bottomAnchor, constant: padding),
            authorTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            authorTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            authorTextField.heightAnchor.constraint(equalToConstant: height),
            
            callToActionBatton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            callToActionBatton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            callToActionBatton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            callToActionBatton.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}

extension AddNewItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let compressedImage = image?.jpegData(compressionQuality: 0.1)
        
        selectedImageView.image = UIImage(data: compressedImage!)
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
        guard let lastLocation = locations.last?.coordinate else { return }
        self.currentLocation = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
        
        let geoCoder = CLGeocoder()
        guard let location = currentLocation else { return }
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placeMark = placemarks?.first else { return }
            guard let streetName = placeMark.thoroughfare else { return }
            guard let streetNumber = placeMark.subThoroughfare else { return }
            self.adressTextField.text = "\(streetName) \(streetNumber)"
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
