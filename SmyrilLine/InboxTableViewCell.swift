//
//  InboxTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/14/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {

    
    @IBOutlet weak var messageTitleLabel: UILabel!
    @IBOutlet weak var messageDetailsLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageReadUnreadStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
