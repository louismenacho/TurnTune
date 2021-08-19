//
//  CheckmarkSettingTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/25/21.
//

import UIKit

class CheckmarkSettingTableViewCell: UITableViewCell {
    
    var isChecked: Bool = false {
        didSet {
            let systemSymbolName = isChecked ? "checkmark.circle.fill" : "circle"
            checkmarkButton.setImage(UIImage(systemName: systemSymbolName), for: .normal)
        }
    }

    var queueType: QueueType = .fair {
        didSet {
            settingNameLabel.text = queueType.rawValue
        }
    }
    
    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var checkmarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
