//
//  CategoryHeaderTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/11/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class CategoryHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
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
