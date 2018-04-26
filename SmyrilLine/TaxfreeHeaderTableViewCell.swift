//
//  TaxfreeHeaderTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 23/4/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class TaxfreeHeaderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var shopDescriptionLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var seeMoreButtonHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
