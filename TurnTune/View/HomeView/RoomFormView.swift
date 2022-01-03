//
//  RoomFormView.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/10/21.
//

import UIKit

protocol RoomFormViewDelegate: AnyObject {
    func roomFormView(_ roomFormView: RoomFormView, selectedSegmentDidChange selectedSegmentIndex: Int)
    func roomFormView(_ roomFormView: RoomFormView, displayNameTextFieldDidChange text: String?)
    func roomFormView(_ roomFormView: RoomFormView, roomCodeTextFieldDidChange text: String?)
    func roomFormView(_ roomFormView: RoomFormView, joinButtonPressed button: UIButton)
    func roomFormView(_ roomFormView: RoomFormView, spotifyButtonPressed button: UIButton)
}

class RoomFormView: UIStackView {
    
    weak var delegate: RoomFormViewDelegate?
    
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
        delegate?.roomFormView(self, selectedSegmentDidChange: sender.selectedSegmentIndex)
    }
    
    @IBAction func displayNameTextFieldDidChange(_ sender: UITextField) {
        delegate?.roomFormView(self, displayNameTextFieldDidChange: sender.text)
    }
    
    @IBAction func roomCodeTextFieldDidChange(_ sender: UITextField) {
        delegate?.roomFormView(self, roomCodeTextFieldDidChange: sender.text)
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        delegate?.roomFormView(self, joinButtonPressed: sender)
    }
    
    @IBAction func spotifyButtonPressed(_ sender: UIButton) {
        delegate?.roomFormView(self, spotifyButtonPressed: sender)
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

extension RoomFormView: UITextFieldDelegate {
    
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
