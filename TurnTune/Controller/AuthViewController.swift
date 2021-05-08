//
//  AuthViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/18/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AuthViewController: UIViewController {
    
    var authViewModel = AuthViewModel()

    @IBOutlet weak var roomCodeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        roomCodeTextField.text = "ALNE"
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomViewController" {
            let roomViewController = segue.destination as! RoomViewController
            roomViewController.roomViewModel = RoomViewModel(roomPath: authViewModel.roomPath)
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        authViewModel.join(room: roomCodeTextField.text!, displayName: nameTextField.text!) {
            self.performSegue(withIdentifier: "RoomViewController", sender: self)
        }
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        authViewModel.host(displayName: nameTextField.text!) {
            self.performSegue(withIdentifier: "RoomViewController", sender: self)
        }
    }
}

extension AuthViewController: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("did initiate")
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print(error)
    }
}
