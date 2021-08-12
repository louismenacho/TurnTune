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

class HomeViewController: UIViewController {
    
    var authViewModel = HomeViewModel()
    
    @IBOutlet weak var displayNameTextField: InputTextField!
    @IBOutlet weak var roomIDTextField: InputTextField!
    @IBOutlet weak var stackViewContainerCenterXConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackViewContainerCenterXConstraint.constant = view.frame.width/2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func segmentedControlSwitched(_ sender: HeaderSegmentedControl) {
        UIView.animate(withDuration: 0.35) { [self] in
            if sender.selectedSegmentIndex == 0 {
                stackViewContainerCenterXConstraint.constant = view.frame.width/2
            }
            if sender.selectedSegmentIndex == 1 {
                stackViewContainerCenterXConstraint.constant = -view.frame.width/2
            }
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: MusicServiceButton) {
        print("joinButtonPressed")
    }
    
    @IBAction func connectSpotifyButtonPressed(_ sender: MusicServiceButton) {
        print("connectSpotifyButtonPressed")
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicServiceCell", for: indexPath)
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    
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
