//
//  GroupChatTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 15/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class GroupChatTableViewCell: UITableViewCell {

    @IBOutlet weak var groupChatCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
