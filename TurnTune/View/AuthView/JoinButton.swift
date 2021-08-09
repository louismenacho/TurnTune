//
//  JoinButton.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/6/21.
//

import UIKit

class JoinButton: UIButton {
    
    var foreLayer = CALayer()
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func customInit() {
        foreLayer.frame = bounds
        foreLayer.backgroundColor = backgroundColor?.cgColor
        layer.addSublayer(foreLayer)
        backgroundColor = .black
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchBegan")
        foreLayer.opacity = 0.7
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchEnded")
        UIView.animate(withDuration: 0.5) { [self] in
            foreLayer.opacity = 1
        }
    }
}
