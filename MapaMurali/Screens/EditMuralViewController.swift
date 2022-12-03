//
//  EditMuralViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 17/11/2022.
//

import UIKit

class EditMuralViewController: AddNewItemViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationController()
    }
    
    var mural: Mural!
    
    init(mural: Mural, databaseManager: DatabaseManager) {
        super.init(databaseManager: databaseManager)
        self.mural = mural
        
        NetworkManager.shared.downloadImage(from: mural.imageURL) { image in
            DispatchQueue.main.async {
                self.selectedImageView.image = image
                self.selectedImageView.didSelectedImage()
                self.removeImageButton.alpha = 1.0
            }
        }

        self.adressTextField.text = mural.adress
        self.cityTextField.text = mural.city
        self.authorTextField.text = mural.author
        self.callToActionBatton.set(color: MMColors.primary, title: "Zapisz zmiany")
        self.selectedImageViewTopAnchorConstant = 100
    }
    
    func configureNavigationController() {
        navigationController?.navigationBar.isHidden = false
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(self.dismissVC))
        navigationItem.leftBarButtonItem = backButton
        title = "Edytuj mural"
        navigationController?.navigationBar.tintColor = MMColors.primary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func callToActionButtonTapped() {
        print("🟡 Save edited mural tapped")
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
