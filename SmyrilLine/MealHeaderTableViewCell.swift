//
//  MealHeaderTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/3/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MealHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headernameLabel: UILabel!
    @IBOutlet weak var expandCollapseImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.borderWidth = 1
        let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
        self.containerView.layer.borderColor = color.cgColor
        // Initialization code
        self.containerView.layer.cornerRadius = 3
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 3
        self.containerView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
