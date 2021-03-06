//
//  AgegroupCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/14/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class AgegroupCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ageTitleLabel: UILabel!
    @IBOutlet weak var ageDescriptionLabel: UILabel!
    @IBOutlet weak var ageGroupImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ageDescriptionLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var selectionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
//        let color = UIColor(red: 159.0/255, green: 206.0/255, blue: 255.0/255, alpha: 1.0)
//        self.layer.borderColor = color.cgColor
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        
        self.containerView.layer.cornerRadius = 3
        self.containerView.layer.masksToBounds = true
        
        self.backgroundColor = UIColor.white
    }
    
}
