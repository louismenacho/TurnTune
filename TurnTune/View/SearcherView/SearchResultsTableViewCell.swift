//
//  SearchResultsTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/18/21.
//

import UIKit
import SDWebImage

protocol SearchResultsTableViewCellDelegate: AnyObject {
    func searchResultsTableViewCell(addButtonPressedFor cell: SearchResultsTableViewCell)
}

class SearchResultsTableViewCell: UITableViewCell {
    
    weak var delegate: SearchResultsTableViewCellDelegate?
    
    var song: Song = Song() {
        didSet {
            albumImageView.sd_setImage(with: URL(string: song.artworkURL), placeholderImage: UIImage(systemName: "photo.fill"))
            songLabel.text = song.name
            artistLabel.text = song.artist
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
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        delegate?.searchResultsTableViewCell(addButtonPressedFor: self)
    }
}
