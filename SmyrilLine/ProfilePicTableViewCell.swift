//
//  ProfilePicTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/30/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class ProfilePicTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profilePicButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profilePicButton.layer.cornerRadius = self.profilePicButton.frame.size.height / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
