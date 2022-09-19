//
//  MMTextField.swift
//  MapaMurali
//
//  Created by Jakub Zajda on 12/09/2022.
//

import UIKit

class MMTextField: UITextField {
    
    enum TextFieldType {
        case email, password, custom
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    convenience init(placeholder: String, type: TextFieldType) {
        self.init(frame: .zero)
        set(placeholder: placeholder, type: type)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        autocorrectionType = .no
        spellCheckingType = .no
        borderStyle = .none
        clearButtonMode = .whileEditing
        
        textColor = .label
        
    }
    
    final func set(placeholder: String, type: TextFieldType) {
        self.placeholder = placeholder
        
        switch type {
        case .email:
            self.keyboardType = .emailAddress
            self.autocapitalizationType = .none
        case .password:
            self.autocapitalizationType = .none
            self.isSecureTextEntry = true
        case .custom:
            self.keyboardType = .default
            self.autocapitalizationType = .words
        }
    }
}
