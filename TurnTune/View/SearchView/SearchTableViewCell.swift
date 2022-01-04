//
//  SearchTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/17/21.
//

import UIKit
import SDWebImage

class SearchTableViewCell: UITableViewCell {
    
    var searchResultItem = SearchResultItem() {
        didSet {
            albumImageView.sd_setImage(with: URL(string: searchResultItem.song.artworkURL), placeholderImage: UIImage(systemName: "image"))
            songTitleLabel.text = searchResultItem.song.name
            artistNamesLabel.text = searchResultItem.song.artist
        }
    }
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNamesLabel: UILabel!
}
