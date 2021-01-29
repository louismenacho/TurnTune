//
//  SongTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/18/21.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        artworkImageView.image = UIImage(systemName: "person.crop.circle")
        nameLabel.text = "Beat it"
        artistNameLabel.text = "Michael Jackson"
    }
}
