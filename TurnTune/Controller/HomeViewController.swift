//
//  HomeViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/18/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var vm = HomeViewModel()
        
    @IBOutlet weak var appearanceSwitch: SwitchControl!
    @IBOutlet weak var formView: RoomFormView!
    @IBOutlet weak var formViewCenterYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSwitch.delegate = self
        formView.delegate = self
        addKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaylistViewController" {
            guard let currentRoom = vm.currentRoom else {
                print("Room is nil on performing segue")
                return
            }
            let vc = segue.destination as! PlaylistViewController
            vc.vm = PlaylistViewModel(currentRoom, vm.spotifySessionManager)
            vc.vm.spotifyConfig = vm.spotifyConfig
        }
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.1) { [self] in
                formViewCenterYConstraint.constant = -(keyboardRect.height - 34)/2
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1) { [self] in
            formViewCenterYConstraint.constant = 0
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        print("viewTapped")
        view.endEditing(true)
    }
}

extension HomeViewController: SwitchControlDelegate {
    func switchControl(_ switchControl: SwitchControl, didToggle isOn: Bool) {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isOn ? .light : .dark
        }
    }
}

extension HomeViewController: RoomFormViewDelegate {
    
    func roomFormView(_ roomFormView: RoomFormView, selectedSegmentDidChange selectedSegmentIndex: Int) {
        
    }
    
    func roomFormView(_ roomFormView: RoomFormView, displayNameTextFieldDidChange text: String?) {
        
    }
    
    func roomFormView(_ roomFormView: RoomFormView, roomCodeTextFieldDidChange text: String?) {
        
    }
    
    func roomFormView(_ roomFormView: RoomFormView, joinButtonPressed button: UIButton) {
        let displayName = roomFormView.displayNameTextField.text!
        let roomCode = roomFormView.roomCodeTextField.text!
        vm.joinRoom(roomID: roomCode, memberName: displayName) { result in
            switch result {
            case .failure(let error):
                if let clientError = error as? ClientError {
                    print(clientError)
                }
                if let repositoryError = error as? RepositoryError {
                    print(repositoryError)
                }
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                }
            }
        }
    }
    
    func roomFormView(_ roomFormView: RoomFormView, spotifyButtonPressed button: UIButton) {
        vm.createRoom(hostName: roomFormView.displayNameTextField.text!) { result in
            switch result {
            case .failure(let error):
                if let clientError = error as? ClientError {
                    print(clientError)
                }
                if let repositoryError = error as? RepositoryError {
                    print(repositoryError)
                }
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                }
            }
        }
    }
}
