//
//  BasicInfoTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class BasicInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoHeaderLabel: UILabel!
    @IBOutlet weak var infoDetailsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
