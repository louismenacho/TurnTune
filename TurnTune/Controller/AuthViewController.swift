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
        roomCodeTextField.text = "HWHC"
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomViewController" {
            let roomViewController = segue.destination as! RoomViewController
            roomViewController.newRoomViewModel = NewRoomViewModel(roomManager: authViewModel.roomManager!)
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        authViewModel.joinRoom(roomId: roomCodeTextField.text!, as: nameTextField.text!) { [self] in
            performSegue(withIdentifier: "RoomViewController", sender: self)
        }
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        authViewModel.hostRoom(as: roomCodeTextField.text!) { [self] in
            performSegue(withIdentifier: "RoomViewController", sender: self)
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
