//
//  HomeViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/18/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var vm: HomeViewModel!
        
    lazy var activityIndicator = ActivityIndicatorView(frame: view.bounds)
    @IBOutlet weak var appearanceSwitch: SwitchControl!
    @IBOutlet weak var formView: RoomFormView!
    @IBOutlet weak var formViewCenterYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSwitch.delegate = self
        formView.delegate = self
        addKeyboardObserver()
        appearanceSwitch.setOn(traitCollection.userInterfaceStyle == .light ? true : false)
        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        vm = HomeViewModel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaylistViewController" {
            guard let currentMember = vm.currentMember else { return }
            guard let currentRoom = vm.currentRoom else { return }
            let vc = segue.destination as! PlaylistViewController
            vc.vm = PlaylistViewModel(currentMember, currentRoom, vm.spotifySessionManager)
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
        switchControl.setThumbImage(UIImage(systemName: isOn ? "sun.min.fill" : "moon.fill"))
        UIApplication.shared.windows.forEach { window in
            UIView.animate(withDuration: 0.3) {
                window.overrideUserInterfaceStyle = isOn ? .light : .dark
            }
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
        view.endEditing(true)
        let displayName = roomFormView.displayNameTextField.text!
        let roomCode = roomFormView.roomCodeTextField.text!
        activityIndicator.startAnimating()
        vm.joinRoom(room: roomCode, memberName: displayName) { error in
            if let error = error {
                print("roomFormView join error: \(error)")
                self.presentAlert(title: error.localizedDescription, actionTitle: "Dismiss")
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func roomFormView(_ roomFormView: RoomFormView, spotifyButtonPressed button: UIButton) {
        view.endEditing(true)
        activityIndicator.startAnimating()
        vm.createRoom(hostName: roomFormView.displayNameTextField.text!) { error in
            if let error = error {
                print("roomFormView create error: \(error)")
                self.presentAlert(title: error.localizedDescription, actionTitle: "Dismiss")
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
