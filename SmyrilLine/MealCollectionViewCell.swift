//
//  MealCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/3/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MealCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
                self.layer.borderWidth = 1
                let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
                self.layer.borderColor = color.cgColor
                // Initialization code
                self.layer.cornerRadius = 3
                self.layer.masksToBounds = true
                self.layer.cornerRadius = 3
                self.layer.masksToBounds = true
    }
    
    
}
