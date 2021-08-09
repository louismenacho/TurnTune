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
    @IBOutlet weak var roomIDField: CodeEntryView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerViewController" {
//            let playerViewController = segue.destination as! PlayerViewController
//            playerViewController.navigationItem.title = RoomService().currentRoomID
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
//        authViewModel.joinRoom(roomID: roomIDField.roomID, as: "") { [self] in
//            performSegue(withIdentifier: "PlayerViewController", sender: self)
//        }
    }
    
}

extension AuthViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicServiceCell", for: indexPath)
        return cell
    }
}

extension AuthViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
