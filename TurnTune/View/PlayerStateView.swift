//
//  PlayerStateView.swift
//  TurnTune
//
//  Created by Louis Menacho on 7/30/21.
//

import Foundation

import UIKit
import SDWebImage

class PlayerStateView: UIView {
        
    var playerState = PlayerState() {
        didSet {
            albumImageView.sd_setImage(with: URL(string: playerState.currentSong.artworkURL), placeholderImage: UIImage(systemName: "photo.fill"))
            songLabel.text = playerState.currentSong.name
            artistLabel.text = playerState.currentSong.artist
        }
    }
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        albumImageView.image = UIImage(systemName: "photo.fill")
        songLabel.text = "Beat it"
        artistLabel.text = "Michael Jackson"
    }
}
