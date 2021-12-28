//
//  PlaylistTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/14/21.
//

import UIKit
import SDWebImage

class PlaylistTableViewCell: UITableViewCell {

    var song = Song() {
        didSet {
            imageView?.sd_setImage(with: URL(string: song.artworkURL), placeholderImage: UIImage(systemName: "image"))
            textLabel?.text = song.name
            detailTextLabel?.text = song.artist
        }
    }
}
