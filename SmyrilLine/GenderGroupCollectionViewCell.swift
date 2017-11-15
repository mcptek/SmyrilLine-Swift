//
//  GenderGroupCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/14/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class GenderGroupCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var genderNameTitleLabel: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var genderContainerView: UIView!
    @IBOutlet weak var selectionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
//        let color = UIColor(red: 159.0/255, green: 206.0/255, blue: 255.0/255, alpha: 1.0)
//        self.layer.borderColor = color.cgColor
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.genderContainerView.layer.cornerRadius = 3
        self.genderContainerView.layer.masksToBounds = true
        
        self.backgroundColor = UIColor.white
    }
}
