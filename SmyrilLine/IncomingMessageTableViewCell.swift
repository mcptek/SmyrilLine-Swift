//
//  IncomingMessageTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/22/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class IncomingMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messagelabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // corner radius
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 15
        //self.containerView.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        self.userImageView.layer.masksToBounds = true
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
