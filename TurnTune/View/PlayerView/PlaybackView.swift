//
//  PlaybackView.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/1/21.
//

import UIKit

protocol PlaybackViewDelegate: AnyObject {
    func playbackView(playButtonPressedFor playbackView: PlaybackView)
    func playbackView(pauseButtonPressedFor playbackView: PlaybackView)
}

class PlaybackView: UIView {
    
    weak var delegate: PlaybackViewDelegate?

    var playerState = PlayerState() {
        didSet {
            albumImageView.sd_setImage(with: URL(string: playerState.currentSong.artworkURL), placeholderImage: UIImage(systemName: "photo.fill"))
            songLabel.text = playerState.currentSong.name
            artistLabel.text = playerState.currentSong.artist
            
            let imageName = playerState.isPaused ? "play.circle" : "pause.circle"
            playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    

    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        if sender.image(for: .normal) == UIImage(systemName: "play.circle") {
            delegate?.playbackView(playButtonPressedFor: self)
        }
        if sender.image(for: .normal) == UIImage(systemName: "pause.circle") {
            delegate?.playbackView(pauseButtonPressedFor: self)
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        
    }
}
