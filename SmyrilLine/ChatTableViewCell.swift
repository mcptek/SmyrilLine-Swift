//
//  ChatTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/23/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var userCollectionView: UICollectionView!
    
    @IBOutlet weak var statusHeaderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
