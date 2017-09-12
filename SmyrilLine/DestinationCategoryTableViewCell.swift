//
//  DestinationCategoryTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/7/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class DestinationCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var leftContainerView: UIView!
    @IBOutlet weak var leftCategoryImageView: UIImageView!
    @IBOutlet weak var leftCategoryNameLabel: UILabel!
    @IBOutlet weak var rightContainerView: UIView!
    @IBOutlet weak var rightCategotyImageView: UIImageView!
    @IBOutlet weak var rightCategoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.leftContainerView.layer.cornerRadius = 2
        self.leftContainerView.layer.masksToBounds = true
        self.rightContainerView.layer.cornerRadius = 2
        self.rightContainerView.layer.masksToBounds = true        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
