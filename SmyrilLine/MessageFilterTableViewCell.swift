//
//  MessageFilterTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/14/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MessageFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var ageGroupCollectionView: UICollectionView!
    @IBOutlet weak var ageGroupCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
