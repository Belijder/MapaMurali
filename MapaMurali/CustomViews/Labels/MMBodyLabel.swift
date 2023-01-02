//
//  MMBodyLabel.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/09/2022.
//

import UIKit

class MMBodyLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
    }
    
    private func configure() {
        textColor = .secondaryLabel
        font = UIFont.systemFont(ofSize: 15)
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.75
        lineBreakMode = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createStringWithUnderlinedTextForRegistracionForm(plainText: String, textToUnderline: String) {
        let underlinedText = NSMutableAttributedString(string: textToUnderline)
        underlinedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: textToUnderline.count))
        underlinedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(location: 0, length: textToUnderline.count))
        
        let fullString = NSMutableAttributedString(string: "\(plainText) ")
        fullString.append(NSAttributedString(attributedString: underlinedText))
        
        attributedText = fullString
    }
    
}
