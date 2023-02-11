//
//  FullScreenImageVC.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 11/02/2023.
//

import UIKit

class FullScreenImageVC: UIViewController {
    
    // MARK: - Properties
    private let image: UIImage
    private let imageView = UIImageView()
    let closeButton = MMCircleButton(color: .white, systemImageName: "xmark")

    
    // MARK: - Initialization
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubviews(imageView, closeButton)
        configureCloseButton()
        configureImageView()
    }
    
    
    // MARK: - Set up
    private func configureCloseButton() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        closeButton.configuration?.baseBackgroundColor = .clear
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
    }
    
    
    private func configureImageView() {
        imageView.frame = view.bounds
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
    
    
    // MARK: - Actions
    @objc private func dismissVC() {
        self.dismiss(animated: true)
    }
}
