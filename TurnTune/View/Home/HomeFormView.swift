//
//  HomeFormView.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/10/21.
//

import UIKit

protocol HomeFormViewDelegate: AnyObject {
    func formView(_ formView: HomeFormView, selectedSegmentDidChange selectedSegmentIndex: Int)
    func formView(_ formView: HomeFormView, displayNameTextFieldDidChange text: String?)
    func formView(_ formView: HomeFormView, roomCodeTextFieldDidChange text: String?)
    func formView(_ formView: HomeFormView, joinButtonPressed button: UIButton)
    func formView(_ formView: HomeFormView, spotifyButtonPressed button: UIButton)
}

class HomeFormView: UIStackView {
    
    var delegate: HomeFormViewDelegate?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var roomCodeTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var spotifyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        displayNameTextField.delegate = self
        roomCodeTextField.delegate = self
        showJoinRoomOptions()
    }

    @IBAction func selectedSegmentDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showJoinRoomOptions()
        } else {
            showCreateRoomOptions()
        }
        delegate?.formView(self, selectedSegmentDidChange: sender.selectedSegmentIndex)
    }
    
    @IBAction func displayNameTextFieldDidChange(_ sender: UITextField) {
        delegate?.formView(self, displayNameTextFieldDidChange: sender.text)
    }
    
    @IBAction func roomCodeTextFieldDidChange(_ sender: UITextField) {
        delegate?.formView(self, roomCodeTextFieldDidChange: sender.text)
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        delegate?.formView(self, joinButtonPressed: sender)
    }
    
    @IBAction func spotifyButtonPressed(_ sender: UIButton) {
        delegate?.formView(self, spotifyButtonPressed: sender)
    }
    
    private func showJoinRoomOptions() {
        roomCodeTextField.isHidden = false
        joinButton.isHidden = false
        spotifyButton.isHidden = true
    }
    
    private func showCreateRoomOptions() {
        roomCodeTextField.isHidden = true
        joinButton.isHidden = true
        spotifyButton.isHidden = false
    }
    
    private func isDisplayNameTextChangeValid(shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    private func isRoomCodeTextChangeValid(shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
}

extension HomeFormView: UITextFieldDelegate {
    
    func textView(_ textView: UITextField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == displayNameTextField {
            return isDisplayNameTextChangeValid(shouldChangeTextIn: range, replacementText: text)
        } else
        
        if textView == roomCodeTextField {
            return isRoomCodeTextChangeValid(shouldChangeTextIn: range, replacementText: text)
        }
        
        return true
    }
}
