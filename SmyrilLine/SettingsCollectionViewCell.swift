//
//  SettingsCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/20/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class SettingsCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categorySelectionImageView: UIImageView!
    @IBOutlet weak var transparentImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var categoryDescriptionNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        let color = UIColor(colorLiteralRed: 19/255, green: 148/255, blue: 255/255, alpha: 1.0)
        self.layer.borderColor = color.cgColor
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        
        self.containerView.layer.cornerRadius = 3
        self.containerView.layer.masksToBounds = true
    }
}
