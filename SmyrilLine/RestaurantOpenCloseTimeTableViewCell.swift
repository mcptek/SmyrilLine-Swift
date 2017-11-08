//
//  RestaurantOpenCloseTimeTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/2/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class RestaurantOpenCloseTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var parentContainerView: UIView!
    @IBOutlet weak var breakfastTimeLabel: UILabel!
    @IBOutlet weak var lunchTimeLabel: UILabel!
    @IBOutlet weak var dinnerTimeLabel: UILabel!
    @IBOutlet weak var expandCollpaseImageView: UIImageView!
    @IBOutlet weak var containerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.parentContainerView.layer.borderWidth = 1
        let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
        self.parentContainerView.layer.borderColor = color.cgColor
        // Initialization code
        self.parentContainerView.layer.cornerRadius = 3
        self.parentContainerView.layer.masksToBounds = true
        /*
        // Initialization code
        self.openCloseTimeContainerView.layer.borderWidth = 1
       // let color = UIColor(colorLiteralRed: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.openCloseTimeContainerView.layer.borderColor = color.cgColor
        // Initialization code
        self.openCloseTimeContainerView.layer.cornerRadius = 3
        self.openCloseTimeContainerView.layer.masksToBounds = true
        self.openCloseTimeContainerView.layer.cornerRadius = 3
        self.openCloseTimeContainerView.layer.masksToBounds = true
 */
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
