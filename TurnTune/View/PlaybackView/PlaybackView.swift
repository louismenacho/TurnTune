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
            
            let backgroundImageName = playerState.isPaused ? "play.circle.fill" : "pause.circle.fill"
            playPauseButton.setBackgroundImage(UIImage(systemName: backgroundImageName), for: .normal)
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("PlaybackView", owner: self, options: .none)
        contentView.frame = self.bounds
        addSubview(contentView)
    }

    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        if sender.backgroundImage(for: .normal) == UIImage(systemName: "play.circle.fill") {
            delegate?.playbackView(playButtonPressedFor: self)
        }
        if sender.backgroundImage(for: .normal) == UIImage(systemName: "pause.circle.fill") {
            delegate?.playbackView(pauseButtonPressedFor: self)
        }
    }
    
}
