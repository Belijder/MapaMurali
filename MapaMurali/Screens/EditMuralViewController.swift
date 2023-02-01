//
//  EditMuralViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/11/2022.
//

import UIKit

class EditMuralViewController: AddNewItemViewController {
   
    //MARK: - Properties
    var mural: Mural!
    
    
    //MARK: - Initialization
    init(mural: Mural, databaseManager: DatabaseManager) {
        super.init(databaseManager: databaseManager)
        self.mural = mural
        
        do {
            try ImagesManager.shared.fetchDownsampledImageFromDirectory(from: mural.imageURL,
                                                                        imageType: .fullSize,
                                                                        name: mural.docRef,
                                                                        uiImageSize: CGSize(width: 300, height: 400),
                                                                        completed: { [weak self] image in
                guard let self = self else { return }
                self.selectedImageView.image = image
                self.selectedImageView.didSelectedImage()
                self.removeImageButton.alpha = 1.0
            })
        } catch {
            ImagesManager.shared.downloadImage(from: mural.imageURL, imageType: .fullSize, name: mural.docRef) { image in
                DispatchQueue.main.async {
                    self.selectedImageView.image = image
                    self.selectedImageView.didSelectedImage()
                    self.removeImageButton.alpha = 1.0
                }
            }
        }

        self.addressTextField.text = mural.address
        self.cityTextField.text = mural.city
        self.authorTextField.text = mural.author
        self.callToActionBatton.set(color: MMColors.primary, title: "Zapisz zmiany")
        self.selectedImageViewTopAnchorConstant = 100
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationController()
        removeImageButton.removeFromSuperview()
    }
    
    
    //MARK: - Set up
    func configureNavigationController() {
        navigationController?.navigationBar.isHidden = false
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(self.dismissVC))
        navigationItem.leftBarButtonItem = backButton
        title = "Edytuj mural"
        navigationController?.navigationBar.tintColor = MMColors.primary
    }
    
    //MARK: - Actions
    override func callToActionButtonTapped() {
        self.showLoadingView(message: "Zapisywanie zmian...")
        
        print("🟡 Save edited mural tapped")
        
        vm.address = addressTextField.text
        vm.city = cityTextField.text
        
        guard let address = vm.address, let city = vm.city else {
            self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.invalidAddress.rawValue, buttonTitle: "Ok")
            return
        }
        
        let addressString = "\(address), \(city)"
        
        vm.getCoordinate(addressString: addressString) { location, error in
            if error != nil {
                self.presentMMAlert(title: "Ups! Coś poszło nie tak.", message: MMError.invalidAddress.rawValue, buttonTitle: "Ok")
                return
            }
            
            let data = EditedDataForMural(location: location,
                                          address: address,
                                          city: city,
                                          author: self.authorTextField.text ?? "")
            
            self.databaseManager.updateMuralInformations(id: self.mural.docRef, data: data)
        }
    }
    
    
    override func cameraImageViewTapped() { }
    
    
    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
