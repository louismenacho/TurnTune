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
            hostIndicatorLabel.isHidden = !member.isHost
            
            if isCurrentMemberHost {
                isUserInteractionEnabled = !member.isHost
                accessoryType = !member.isHost ? .disclosureIndicator : .none
            }
        }
    }
    
    var isCurrentMemberHost: Bool = false {
        didSet {
            isUserInteractionEnabled = isCurrentMemberHost
            accessoryType = isCurrentMemberHost ? .disclosureIndicator : .none
        }
    }
    
    @IBOutlet weak var memberDisplayNameLabel: UILabel!
    @IBOutlet weak var hostIndicatorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
