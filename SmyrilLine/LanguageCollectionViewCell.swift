//
//  LanguageCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 30/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class LanguageCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var languageImageView: UIImageView!
    @IBOutlet weak var languageTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.languageImageView.layer.cornerRadius = self.languageImageView.frame.size.height / 2
        
    }
    
}
