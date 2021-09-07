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
    
    var searchResultItem = SearchResultItem() {
        didSet {
            albumImageView.sd_setImage(with: URL(string: searchResultItem.song.artworkURL), placeholderImage: UIImage(systemName: "photo.fill"))
            songLabel.text = searchResultItem.song.name
            artistLabel.text = searchResultItem.song.artist
            let imageName = searchResultItem.isAdded ? "checkmark.circle.fill" : "plus.circle"
            addButton.setImage(UIImage(systemName: imageName), for: .normal)
            addButton.isUserInteractionEnabled = !searchResultItem.isAdded
        }
    }
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        albumImageView.image = UIImage(systemName: "photo.fill")
        songLabel.text = "Beat it"
        artistLabel.text = "Michael Jackson"
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        delegate?.searchResultsTableViewCell(addButtonPressedFor: self)
    }
}
