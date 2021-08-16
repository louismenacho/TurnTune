//
//  HomeViewSegmentedControl.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/10/21.
//

import UIKit

@IBDesignable
class HomeViewSegmentedControl: UISegmentedControl {

    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = 24
        layer.borderWidth = 2
        layer.borderColor = UIColor.secondarySystemBackground.cgColor
    }

}
