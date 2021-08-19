//
//  MemberTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/17/21.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    var member = Member() {
        didSet {
            memberDisplayNameLabel.text = member.displayName
        }
    }
    
    @IBOutlet weak var memberDisplayNameLabel: UILabel!
    @IBOutlet weak var hostIndicatorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hostIndicatorLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
