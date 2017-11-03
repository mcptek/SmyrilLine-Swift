//
//  MealDetailsTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/3/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MealDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var mealCollectionView: UICollectionView!
    @IBOutlet weak var mealCollectionViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.mealCollectionView.layer.borderWidth = 1
//        let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
//        self.mealCollectionView.layer.borderColor = color.cgColor
//        // Initialization code
//        self.mealCollectionView.layer.cornerRadius = 3
//        self.mealCollectionView.layer.masksToBounds = true
//        self.mealCollectionView.layer.cornerRadius = 3
//        self.mealCollectionView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
