////
////  FavoriteCounterView.swift
////  MapaMurali
////
////  Created by Jakub Zajda on 23/10/2022.
////
//
//import UIKit
//
////DO USUNIĘCIA JEŚLI SIE OKAŻE ŻE DZIAŁA FAVORITECOUNTER W NOWEJ WERSJI
//
//
//class MMFavoriteCounterView: UIView {
//
////    let heartImageView = UIImageView(frame: .zero)
//    let counterLabel = MMTitleLabel(frame: .zero)
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    convenience init(imageHeight: CGFloat, counter: Int, fontSize: CGFloat) {
//        self.init(frame: .zero)
//        configure(imageHeight: imageHeight, counter: counter, fontSize: fontSize)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func configure(imageHeight: CGFloat, counter: Int, fontSize: CGFloat) {
////        heartImageView.translatesAutoresizingMaskIntoConstraints = false
//        translatesAutoresizingMaskIntoConstraints = false
////        heartImageView.addSubview(counterLabel)
////        addSubviews(heartImageView)
//
//        addSubview(counterLabel)
//
//        counterLabel.textAlignment = .center
//        counterLabel.font = UIFont.systemFont(ofSize: fontSize)
//        //counterLabel.text = "\(counter)"
//        counterLabel.textColor = .white
//
////        heartImageView.image = UIImage(systemName: "heart.fill")
////        heartImageView.contentMode = .scaleAspectFit
////        heartImageView.tintColor = .systemRed
////        heartImageView.clipsToBounds = true
//
//
//
////        let configuration = UIImage.SymbolConfiguration(paletteColors: [.systemRed])
////        configuration.applying(UIImage.SymbolConfiguration(pointSize: fontSize))
//        let imageAttachment = NSTextAttachment()
//        imageAttachment.image = UIImage(systemName: "heart.fill")
//        let fullString = NSMutableAttributedString(string: "kurwa \(counter)")
//        fullString.append(NSAttributedString(attachment: imageAttachment))
//
//        counterLabel.attributedText = fullString
//
//        NSLayoutConstraint.activate([
////            heartImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
////            heartImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
////            heartImageView.heightAnchor.constraint(equalToConstant: imageHeight),
////            heartImageView.widthAnchor.constraint(equalToConstant: imageHeight),
////
////            counterLabel.centerXAnchor.constraint(equalTo: heartImageView.centerXAnchor),
////            counterLabel.centerYAnchor.constraint(equalTo: heartImageView.centerYAnchor)
//
//
//            counterLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            counterLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            counterLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            counterLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//        ])
//    }
//
//}
