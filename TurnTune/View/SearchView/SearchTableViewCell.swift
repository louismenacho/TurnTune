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
            imageView?.sd_setImage(with: URL(string: searchResultItem.song.artworkURL), placeholderImage: UIImage(systemName: "image"))
            textLabel?.text = searchResultItem.song.name
            detailTextLabel?.text = searchResultItem.song.artist
        
            textLabel!.isEnabled = !searchResultItem.isAdded
            detailTextLabel!.isEnabled = !searchResultItem.isAdded
        }
    }
}
