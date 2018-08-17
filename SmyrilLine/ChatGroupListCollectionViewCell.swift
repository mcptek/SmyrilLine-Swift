//
//  ChatGroupListCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 15/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class ChatGroupListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var topLeftImageView: UIImageView!
    @IBOutlet weak var topRightImageView: UIImageView!
    @IBOutlet weak var bottomLeftImageView: UIImageView!
    @IBOutlet weak var bottomRightImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.topLeftImageView.layer.cornerRadius = self.topLeftImageView.frame.size.height / 2
        self.topLeftImageView.layer.masksToBounds = true
        self.topRightImageView.layer.cornerRadius = self.topRightImageView.frame.size.height / 2
        self.topRightImageView.layer.masksToBounds = true
        self.bottomLeftImageView.layer.cornerRadius = self.bottomLeftImageView.frame.size.height / 2
        self.bottomLeftImageView.layer.masksToBounds = true
        self.bottomRightImageView.layer.cornerRadius = self.bottomRightImageView.frame.size.height / 2
        self.bottomRightImageView.layer.masksToBounds = true
    }
    
}
