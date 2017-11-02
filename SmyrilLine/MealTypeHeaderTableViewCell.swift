//
//  MealTypeHeaderTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/2/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MealTypeHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var adultButton: UIButton!
    @IBOutlet weak var childButton: UIButton!
    @IBOutlet weak var childrenLabel: UILabel!
    @IBOutlet weak var childLabel: UILabel!
    @IBOutlet weak var parentContainerView: UIView!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var adultContainerView: UIView!
    @IBOutlet weak var childContainerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.parentContainerView.layer.borderWidth = 1
        let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
        self.parentContainerView.layer.borderColor = color.cgColor
        // Initialization code
        self.parentContainerView.layer.cornerRadius = 3
        self.parentContainerView.layer.masksToBounds = true
        self.parentContainerView.layer.cornerRadius = 3
        self.parentContainerView.layer.masksToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
