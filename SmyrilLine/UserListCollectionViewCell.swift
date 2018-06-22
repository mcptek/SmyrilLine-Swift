//
//  UserListCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/23/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class UserListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var onlineTrackerImageView: UIImageView!
    @IBOutlet weak var unreadMessageContainerView: UIView!
    @IBOutlet weak var unreadMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // corner radius
        self.unreadMessageLabel.layer.masksToBounds = true
        self.unreadMessageLabel.layer.cornerRadius = self.unreadMessageLabel.frame.size.height / 2
        //self.containerView.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
    }
}
