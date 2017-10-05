//
//  TaxfreeProductDetailsTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/4/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class TaxfreeProductDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var productDetailsLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var seeMoreButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.borderWidth = 1
        let color = UIColor(colorLiteralRed: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
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
