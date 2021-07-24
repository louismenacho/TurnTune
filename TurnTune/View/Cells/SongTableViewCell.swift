//
//  SearchResultsTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/18/21.
//

import UIKit
import SDWebImage

class SongTableViewCell: UITableViewCell {
    
    var song: Song? {
        didSet {
            songLabel.text = song!.name
            artistLabel.text = song!.artist
            albumImageView.sd_setImage(with: URL(string: song!.artworkURL), placeholderImage: UIImage(systemName: "photo.fill"))
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
