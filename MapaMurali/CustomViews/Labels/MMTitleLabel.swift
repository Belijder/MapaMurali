//
//  MMTitleLabel.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 23/09/2022.
//

import UIKit

class MMTitleLabel: UILabel {

    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    
    //MARK: - Set up
    private func configure() {
        textColor = .label
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.9
        lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createFavoriteCounterTextLabel(counter: Int, imagePointSize: CGFloat) {
        let imageAttachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(pointSize: imagePointSize, weight: .regular)
        imageAttachment.image = UIImage(systemName: "heart.fill", withConfiguration: configuration)?.withTintColor(MMColors.primary)
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " \(counter)"))
        
        attributedText = fullString
    }
    
    
    func createAttributedString(text: String, imageSystemName: String, imagePointSize: CGFloat, color: UIColor) {
        let imageAttachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(pointSize: imagePointSize, weight: .regular)
        imageAttachment.image = UIImage(systemName: imageSystemName, withConfiguration: configuration)?.withTintColor(color)
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " " + text))
        
        attributedText = fullString
    }
}
