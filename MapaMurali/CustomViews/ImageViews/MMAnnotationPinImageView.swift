//
//  MMAnnotationPinImageView.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 02/10/2022.
//
//
//import UIKit
//import MapKit
//
//class MMAnnotationPinImageView: UIImageView {
//
//    var urlString: String?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configure()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    convenience init(annotation: MKAnnotation?) {
//        self.init(frame: .zero)
//        annotation?.subtitle?.flatMap({ string in
//            self.urlString = string
//            downloadImage()
//        })
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            layer.borderColor = MMColors.primary.cgColor
//        }
//    }
//
//    private func configure() {
//        clipsToBounds = true
//        translatesAutoresizingMaskIntoConstraints = false
//    }
//
//    func downloadImage() {
//        guard let url = URL(string: urlString!) else { return }
//        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else { return }
//
//            guard let image = UIImage(data: data) else { return }
//            let thumbnailImage = image.aspectFittedToHeight(50)
//            let circleImage = thumbnailImage.cropImageToCircle()
//
//            DispatchQueue.main.async {
//                self.image = circleImage
//                self.layer.masksToBounds = true
//                self.layer.borderWidth = 2
//                self.layer.borderColor = MMColors.primary.cgColor
//                self.layer.cornerRadius = 19
//            }
//        }
//        dataTask.resume()
//    }
//}
