//
//  MealTypeDescriptionTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/2/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MealTypeDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var maelNameLabel: UILabel!
    @IBOutlet weak var mealNameDetailsLabel: UILabel!
    @IBOutlet weak var onboardPriceLabel: UILabel!
    @IBOutlet weak var priceSaveLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var prebookPriceLabel: UILabel!
    @IBOutlet weak var timeNoteLabel: UILabel!
    @IBOutlet weak var timeHeaderNameLabel: UILabel!
    @IBOutlet weak var SeeMoreButton: UIButton!
    @IBOutlet weak var seeMoreButtonHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
        self.containerView.borders(for: [.left, .bottom, .right,], width: 1, color: color)
        //self.containerView.borders(for: [.all], width: 1, color: color)
        
//        self.containerView.layer.borderWidth = 1
//        let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
//        self.containerView.layer.borderColor = color.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
