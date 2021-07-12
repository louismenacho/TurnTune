//
//  CurrentSongTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/11/21.
//

import UIKit
import SDWebImage

class CurrentSongTableViewCell: UITableViewCell {
    
    var song: Song? {
        didSet {
            albumImageView.sd_setImage(with: URL(string: song?.artworkURL ?? ""), placeholderImage: UIImage(systemName: "photo.fill"))
            songLabel.text = song?.name ?? "No song playing"
            artistLabel.text = song?.artistName ?? ""
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
