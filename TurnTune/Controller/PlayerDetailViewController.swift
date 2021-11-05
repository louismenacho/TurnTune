//
//  PlayerDetailViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/15/21.
//

import UIKit

class PlayerDetailViewController: UIViewController {
    
    var playerViewModel: PlayerViewModel!
    var settingsViewModel: SettingsViewModel!

    @IBOutlet var playbackView: PlaybackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playbackView.playerState = playerViewModel.playerState
        playbackView.delegate = self
        if playerViewModel.musicPlayerService == nil {
            hidePlayerControls()
        }
    }
    
    func hidePlayerControls() {
        playbackView.rewindButton.isHidden = true
        playbackView.playPauseButton.isHidden = true
        playbackView.playNextButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PlayerDetailViewController willAppear")
        
        settingsViewModel.memberListChangeListener { memberList in
            if memberList == nil {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        
        playerViewModel.playerStateChangeListener { playerState in
            self.playbackView.playerState = playerState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("PlayerDetailViewController viewWillDisappear")
        settingsViewModel.removeAllListeners()
        playerViewModel.removeAllListeners()
    }
}

// MARK: - PlaybackViewDelegate
extension PlayerDetailViewController: PlaybackViewDelegate {
    
    func playbackView(rewindButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.rewindSong()
    }
    
    func playbackView(playPauseButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.playerState.isPaused ? playerViewModel.play() : playerViewModel.pause()
    }
    
    func playbackView(playNextButtonPressedFor playbackView: PlaybackView) {
        playerViewModel.playNextSong()
    }
    
    func playbackView(startQueueButtonPressedFor playbackView: PlaybackView) {
    }
    
    func playbackView(resumeQueueButtonPressedFor playbackView: PlaybackView) {
    }
}
