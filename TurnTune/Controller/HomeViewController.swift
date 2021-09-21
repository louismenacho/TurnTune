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
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class HomeViewController: UIViewController {
    
    var homeViewModel = HomeViewModel()
    
    lazy var actvityIndicator = NVActivityIndicatorView(
        frame: view.bounds,
        padding: view.frame.width/2 - 30
    )
    
    @IBOutlet weak var displayNameTextField: HomeViewTextField!
    @IBOutlet weak var roomIDTextField: HomeViewTextField!
    @IBOutlet weak var containerCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewContainerCenterXConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewModel.delegate = self
        displayNameTextField.delegate = self
        roomIDTextField.delegate = self
        displayNameTextField.text = "Louis"
        roomIDTextField.text = "XRXR"
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
            let queueViewController = segue.destination as! PlayerViewController
            queueViewController.searchViewModel = SearchViewModel(musicBrowserService: homeViewModel.musicBrowserService)
            queueViewController.playerViewModel = PlayerViewModel(musicPlayerService: homeViewModel.spotifyMusicPlayerService!)
            queueViewController.navigationItem.title = homeViewModel.roomDataAccess.currentRoomID
        }
    }
    
    @IBAction func segmentedControlSwitched(_ sender: HomeViewSegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            stackViewContainerCenterXConstraint.constant = view.frame.width/2
        }
        if sender.selectedSegmentIndex == 1 {
            stackViewContainerCenterXConstraint.constant = -view.frame.width/2
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func joinButtonPressed(_ sender: HomeViewButton) {
        startActivityIndicator()
        homeViewModel.joinRoom(roomID: roomIDTextField.text!, as: displayNameTextField.text!) { [self] in
            homeViewModel.connectMusicBrowserService()
            performSegue(withIdentifier: "QueueViewController", sender: self)
            stopActivityIndicator()
        }
    }
    
    @IBAction func connectSpotifyButtonPressed(_ sender: HomeViewButton) {
        let displayName = displayNameTextField.text!
        startActivityIndicator()
        homeViewModel.connectMusicPlayerService { [self] in
            homeViewModel.hostRoom(as: displayName) { [self] in
                homeViewModel.connectMusicBrowserService()
                performSegue(withIdentifier: "QueueViewController", sender: self)
                stopActivityIndicator()
            }
        }
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async { [self] in
            view.addSubview(actvityIndicator)
            actvityIndicator.backgroundColor = .black
            actvityIndicator.alpha = 0.5
            actvityIndicator.startAnimating()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async { [self] in
            actvityIndicator.stopAnimating()
            actvityIndicator.removeFromSuperview()
        }
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

extension HomeViewController: ViewModelDelegate {
    func viewModel(_ viewModel: ViewModel, error: ViewModelError) {
        stopActivityIndicator()
        
        var localizedDescription = ""
        switch error {
            case let .httpError(error):
                localizedDescription = error.localizedDescription
            case let .repositoryError(error):
                localizedDescription = error.localizedDescription
            case let .dataAccessError(error):
                localizedDescription = error.localizedDescription
            case let .musicPlayerError(error):
                if case .spotifyAppNotInstalled = error {
                    presentAlert(
                        title: error.localizedDescription,
                        alertStyle: .alert,
                        actionTitles: ["Get Spotify App", "Close"],
                        actionStyles: [.default, .cancel],
                        actions: [
                            { _ in
                                let spotifyAppID = "\(SPTAppRemote.spotifyItunesItemIdentifier())"
                                if let url = URL(string: "itms-apps://apple.com/app/id"+spotifyAppID) {
                                    UIApplication.shared.open(url)
                                }
                            },
                            { _ in }
                        ])
                }
            case let .musicBrowserError(error):
                localizedDescription = error.localizedDescription
            case let .authenticationError(error):
                localizedDescription = error.localizedDescription
        }
        
        if !localizedDescription.isEmpty {
            presentAlert(
                title: localizedDescription,
                alertStyle: .alert,
                actionTitles: ["Close"],
                actionStyles: [.cancel],
                actions: [{_ in }])
        }
    }
}
