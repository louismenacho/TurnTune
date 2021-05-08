//
//  ToggleSettingTableViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 4/25/21.
//

import UIKit

class ToggleSettingTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
