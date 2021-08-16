//
//  PlayerDetailViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/15/21.
//

import UIKit

class PlayerDetailViewController: UIViewController {
    
    var playerState = PlayerState()

    @IBOutlet var playbackView: PlaybackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playbackView.playerState = playerState
    }
}
