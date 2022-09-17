//
//  AddNewViewController.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 30/07/2022.
//

import UIKit
import AVFoundation

class AddNewItemViewController: UIViewController {
    
    let selectedImageView = MMMuralImageView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubViews(selectedImageView)
        configureCameraImageView()
        layoutUI()
        
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
    
    
    private func layoutUI() {
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedImageView.heightAnchor.constraint(equalToConstant: 400),
            selectedImageView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension AddNewItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let compressedImage = image?.jpegData(compressionQuality: 0.3)

        selectedImageView.image = image
        selectedImageView.didSelectedImage()
        
        self.dismiss(animated: true)
    }
}

