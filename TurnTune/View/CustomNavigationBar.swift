//
//  CustomNavigationBar.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/1/21.
//

import UIKit

class CustomNavigationBar: UINavigationBar {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
