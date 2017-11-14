//
//  SettingsHeaderTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/10/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class SettingsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var expandCollapseImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
       // self.layer.borderWidth = 1
        //let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
        //self.layer.borderColor = color.cgColor
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
