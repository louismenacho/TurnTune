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
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        roomCodeTextField.text = "GWGD"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerViewController" {
            let playerViewController = segue.destination as! PlayerViewController
            playerViewController.navigationItem.title = RoomService().currentRoomID
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        authViewModel.joinRoom(roomID: roomCodeTextField.text!, as: nameTextField.text!) { [self] in
            performSegue(withIdentifier: "PlayerViewController", sender: self)
        }
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        authViewModel.hostRoom(as: nameTextField.text!) { [self] in
            performSegue(withIdentifier: "PlayerViewController", sender: self)
        }
    }
}
