//
//  UIView+CornerRadius.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/10/21.
//

import UIKit

extension UIView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
    }
    
}
