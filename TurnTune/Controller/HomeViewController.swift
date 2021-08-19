//
//  HomeViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/18/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    var homeViewModel = HomeViewModel()
    
    @IBOutlet weak var displayNameTextField: HomeViewTextField!
    @IBOutlet weak var roomIDTextField: HomeViewTextField!
    @IBOutlet weak var containerCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewContainerCenterXConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.delegate = self
        roomIDTextField.delegate = self
        displayNameTextField.text = "Louis"
        roomIDTextField.text = "RAAF"
        stackViewContainerCenterXConstraint.constant = view.frame.width/2
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QueueViewController" {
            
        }
    }
    
    @IBAction func segmentedControlSwitched(_ sender: HomeViewSegmentedControl) {
        UIView.animate(withDuration: 0.35) { [self] in
            if sender.selectedSegmentIndex == 0 {
                stackViewContainerCenterXConstraint.constant = view.frame.width/2
            }
            if sender.selectedSegmentIndex == 1 {
                stackViewContainerCenterXConstraint.constant = -view.frame.width/2
            }
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func joinButtonPressed(_ sender: HomeViewButton) {
        homeViewModel.joinRoom(roomID: roomIDTextField.text!, as: displayNameTextField.text!) { [self] in
            performSegue(withIdentifier: "QueueViewController", sender: self)
        }
    }
    
    @IBAction func connectSpotifyButtonPressed(_ sender: HomeViewButton) {
//        homeViewModel.hostRoom(as: displayNameTextField.text!) { [self] in
//            performSegue(withIdentifier: "QueueViewController", sender: self)
//        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.1) { [self] in
                containerCenterYConstraint.constant = -(keyboardRect.height - 34)/2
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1) { [self] in
            containerCenterYConstraint.constant = 0
            view.layoutIfNeeded()
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // allow only letter characters
        if string.rangeOfCharacter(from: CharacterSet.letters.inverted) != nil {
            return false
        }
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under 20 characters if display name text field
        if textField == displayNameTextField {
            return updatedText.count <= 20
        }
        
        // make sure the result is under 4 characters if room ID text field
        if textField == roomIDTextField {
            return updatedText.count <= 4
        }
        
        return true
    }
    
}
