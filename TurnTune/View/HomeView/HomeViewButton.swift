//
//  HomeViewButton.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/9/21.
//

import UIKit

@IBDesignable
class HomeViewButton: UIButton {
    
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
    
    func customInit() {
        customImageView.frame.size = CGSize(width: frame.height/2, height: frame.height/2)
        customImageView.layer.cornerRadius = frame.height/2
        customImageView.contentMode = .scaleAspectFit
        addSubview(customImageView)
        
        darkenLayer.frame = bounds
        darkenLayer.opacity = 0
        darkenLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(darkenLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = customImageView.frame.size
        let imageOrigin = CGPoint(x: titleLabel!.frame.minX - imageSize.width*1.5, y: imageSize.height/2)
        customImageView.frame = CGRect(origin: imageOrigin, size: imageSize)
        darkenLayer.frame = bounds
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
