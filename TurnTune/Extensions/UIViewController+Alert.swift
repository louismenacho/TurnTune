//
//  UIViewController+Alert.swift
//  TurnTune
//
//  Created by Louis Menacho on 9/7/21.
//

import Foundation

extension UIViewController {
    typealias ActionHandler = ((UIAlertAction) -> Void)
    
    func presentAlert(
        title: String? = nil,
        message: String? = nil,
        alertStyle:UIAlertController.Style,
        actionTitles:[String],
        actionStyles:[UIAlertAction.Style],
        actions: [ActionHandler],
        completion: ((UIAlertController) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        actionTitles.enumerated().forEach { index, indexTitle in
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true) {
                completion?(alertController)
            }
        }
    }
}
