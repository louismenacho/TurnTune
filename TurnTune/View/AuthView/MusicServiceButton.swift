//
//  MusicServiceButton.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/9/21.
//

import UIKit

@IBDesignable
class MusicServiceButton: UIButton {
    
    var darkenLayer = CALayer()
    var customImageView = UIImageView()
    
    @IBInspectable
    var image: UIImage? {
        get {
            customImageView.image
        }
        set {
            customImageView.image = newValue
            contentEdgeInsets = .init(
                top: 0,
                left: customImageView.frame.width*2,
                bottom: 0,
                right: customImageView.frame.width/2)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        darkenLayer.frame = bounds
    }
    
    func customInit() {
        let imageSize = CGSize(width: frame.height/2, height: frame.height/2)
        let imageOrigin = CGPoint(x: titleLabel!.frame.minX - imageSize.width/4, y: frame.height/4)
        
        customImageView.frame = CGRect(origin: imageOrigin, size: imageSize)
        customImageView.layer.cornerRadius = customImageView.frame.height/2
        customImageView.contentMode = .scaleAspectFit
        addSubview(customImageView)
        
        darkenLayer.frame = bounds
        darkenLayer.opacity = 0
        darkenLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(darkenLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        darkenLayer.opacity = 0.3
        titleLabel?.alpha = 0.7
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.5) { [self] in
            darkenLayer.opacity = 0
            titleLabel?.alpha = 1
        }
    }
}
