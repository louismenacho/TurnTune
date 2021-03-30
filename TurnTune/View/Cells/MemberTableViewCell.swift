//
//  MemberTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 2/9/21.
//

import UIKit

class MemberTableViewCell: UITableViewCell {

    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
