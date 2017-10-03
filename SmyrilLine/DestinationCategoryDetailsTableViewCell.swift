//
//  DestinationCategoryDetailsTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/28/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class DestinationCategoryDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerTitleSeeMoreButton: UIButton!
    @IBOutlet weak var seeMoreButtonHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
