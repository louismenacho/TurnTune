//
//  QueueModeTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/25/21.
//

import UIKit

class QueueModeTableViewCell: UITableViewCell {

    var queueType: QueueType = .fair {
        didSet {
            queueModeLabel.text = queueType.rawValue.capitalized
        }
    }
    
    var isCurrentMemberHost: Bool = false {
        didSet {
            isUserInteractionEnabled = isCurrentMemberHost
            accessoryType = isCurrentMemberHost ? .disclosureIndicator : .none
        }
    }
    
    @IBOutlet weak var queueModeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
