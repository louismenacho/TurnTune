//
//  SearchResultsTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/18/21.
//

import UIKit
import SDWebImage

class SongTableViewCell: UITableViewCell {
    
    var queueItem: QueueItem = QueueItem(song: Song()) {
        didSet {
            albumImageView.sd_setImage(with: URL(string: queueItem.song.artworkURL), placeholderImage: UIImage(systemName: "photo.fill"))
            songLabel.text = queueItem.song.name
            artistLabel.text = queueItem.song.artist
            memberLabel.text = "@"+queueItem.addedBy.displayName
        }
    }
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    
    override func awakeFromNib() {
        albumImageView.image = UIImage(systemName: "photo.fill")
        songLabel.text = "Beat it"
        artistLabel.text = "Michael Jackson"
    }
}
