//
//  SwitchControl.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/12/21.
//

import UIKit

protocol SwitchControlDelegate: AnyObject {
    func switchControl(_ switchControl: SwitchControl, didToggle isOn: Bool)
}

class SwitchControl: UIControl {
    
    weak var delegate: SwitchControlDelegate?
    
    var isOn: Bool = true

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        toggle()
    }
    
    func toggle() {
        isOn.toggle()
        centerXConstraint.constant *= -1
        delegate?.switchControl(self, didToggle: isOn)
    }
    
    func setOn(_ on : Bool) {
        if isOn != on {
            toggle()
        }
    }
    
    func setThumbImage(_ image: UIImage) {
        thumbImageView.image = image
    }
}
