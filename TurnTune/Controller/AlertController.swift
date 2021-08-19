//
//  AlertController.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/18/21.
//

import Foundation


class AlertController {
    
    let viewController: UIViewController
    
    init(for viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(title: String, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { alert.addAction($0) }
        viewController.present(alert, animated: true)
    }
    
    func createAlertActions(titles: [String], handler: ((UIAlertAction) -> Void)? = nil) -> [UIAlertAction] {
        return titles.map { UIAlertAction(title: $0, style: .default, handler: handler) }
    }
    
    
}
