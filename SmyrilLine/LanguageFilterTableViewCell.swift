//
//  LanguageFilterTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/15/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class LanguageFilterTableViewCell: UITableViewCell {

    
    @IBOutlet weak var languageCollectionView: UICollectionView!
    @IBOutlet weak var languageCollectionViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
