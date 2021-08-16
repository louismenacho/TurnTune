//
//  HomeViewTextField.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/10/21.
//

import UIKit

@IBDesignable
class HomeViewTextField: UITextField {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 2
        layer.borderColor = UIColor.secondarySystemBackground.cgColor
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 0, left: 20, bottom: 0, right: 0))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 0, left: 20, bottom: 0, right: 0))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 0, left: 20, bottom: 0, right: 0))
    }
}

