//
//  CurrentSongTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/11/21.
//

import UIKit

class CurrentSongTableViewCell: UITableViewCell {
    
    var song: Song? {
        didSet {
            songLabel.text = song!.name
            artistLabel.text = song!.artistName
        }
    }
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        songLabel.text = "Beat it"
        artistLabel.text = "Michael Jackson"
    }
}
