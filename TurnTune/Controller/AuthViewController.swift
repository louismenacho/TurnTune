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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomViewController" {
            let roomViewController = segue.destination as! RoomViewController
            let roomDocumentRef = authViewModel.roomDocumentRef!
            roomViewController.roomViewModel = RoomViewModel(roomDocumentRef)
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        authViewModel.join(room: roomCodeTextField.text!, name: nameTextField.text!) { result in
            switch result {
            case.failure(let error):
                print(error.localizedDescription)
            case .success:
                self.performSegue(withIdentifier: "RoomViewController", sender: self)
            }
        }
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        authViewModel.host(name: nameTextField.text!) { result in
            switch result {
            case.failure(let error):
                print(error.localizedDescription)
            case .success:
                self.performSegue(withIdentifier: "RoomViewController", sender: self)
            }
        }
    }
}
