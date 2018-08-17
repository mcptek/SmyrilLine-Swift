//
//  AllUserCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 13/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class AllUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userSelectionImageview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
    }
}
