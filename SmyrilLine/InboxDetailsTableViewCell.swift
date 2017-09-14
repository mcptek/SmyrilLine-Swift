//
//  InboxDetailsTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/14/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class InboxDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageDetailsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
