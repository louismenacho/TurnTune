//
//  MemberCollectionViewCell.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/18/21.
//

import UIKit

class MemberCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        
        imageView.image = UIImage(systemName: "person.crop.circle")
    }
}
