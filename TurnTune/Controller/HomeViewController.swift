//
//  HomeViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 6/18/20.
//  Copyright © 2020 Louis Menacho. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
        
    @IBOutlet weak var appearanceSwitch: SwitchControl!
    @IBOutlet weak var sessionFormView: SessionFormView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSwitch.delegate = self
        sessionFormView.delegate = self
    }
}

extension HomeViewController: SwitchControlDelegate {
    func switchControl(_ switchControl: SwitchControl, didToggle isOn: Bool) {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isOn ? .light : .dark
        }
    }
}

extension HomeViewController: SessionFormViewDelegate {
    
    func sessionFormView(_ sessionFormView: SessionFormView, selectedSegmentDidChange selectedSegmentIndex: Int) {
        
    }
    
    func sessionFormView(_ sessionFormView: SessionFormView, displayNameTextFieldDidChange text: String?) {
        
    }
    
    func sessionFormView(_ sessionFormView: SessionFormView, roomCodeTextFieldDidChange text: String?) {
        
    }
    
    func sessionFormView(_ sessionFormView: SessionFormView, joinButtonPressed button: UIButton) {
        
    }
    
    func sessionFormView(_ sessionFormView: SessionFormView, spotifyButtonPressed button: UIButton) {
        
    }
}
