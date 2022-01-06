//
//  UIViewController+Alert.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/5/22.
//

import Foundation

extension UIViewController {
    
    func presentAlert(
        title: String,
        message: String? = nil,
        actionTitle: String,
        actionStyle: UIAlertAction.Style,
        action: @escaping (UIAlertAction) -> Void)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove", style: actionStyle, handler: action))
        present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        dismiss(animated: true, completion: nil)
    }
}
 
