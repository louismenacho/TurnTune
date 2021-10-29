//
//  PlaybackView.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/1/21.
//

import UIKit

protocol PlaybackViewDelegate: AnyObject {
    func playbackView(rewindButtonPressedFor playbackView: PlaybackView)
    func playbackView(playPauseButtonPressedFor playbackView: PlaybackView)
    func playbackView(playNextButtonPressedFor playbackView: PlaybackView)
    func playbackView(startQueueButtonPressedFor playbackView: PlaybackView)
}

class PlaybackView: UIView {
    
    weak var delegate: PlaybackViewDelegate?

    var playerState = PlayerState() {
        didSet {
            albumImageView.sd_setImage(with: URL(string: playerState.queueItem.song.artworkURL), placeholderImage: UIImage(systemName: "photo.fill"))
            songLabel.text = playerState.queueItem.song.name
            artistLabel.text = playerState.queueItem.song.artist
            
            let imageName = playerState.isPaused ? "play.circle" : "pause.circle"
            playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @IBOutlet weak var startQueueButton: UIButton!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playNextButton: UIButton!
    
    @IBAction func logoButtonPressed(_ sender: UIButton) {
        delegate?.playbackView(startQueueButtonPressedFor: self)
    }
    
    @IBAction func startQueueButtonPressed(_ sender: UIButton) {
        delegate?.playbackView(startQueueButtonPressedFor: self)
    }
    
    @IBAction func rewindButtonPressed(_ sender: UIButton) {
        delegate?.playbackView(rewindButtonPressedFor: self)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        delegate?.playbackView(playPauseButtonPressedFor: self)
    }
    
    @IBAction func playNextButtonPressed(_ sender: UIButton) {
        delegate?.playbackView(playNextButtonPressedFor: self)
    }
}
