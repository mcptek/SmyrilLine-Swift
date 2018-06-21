//
//  OutgoingMessageTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/22/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class OutgoingMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // corner radius
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 15
        //self.containerView.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
