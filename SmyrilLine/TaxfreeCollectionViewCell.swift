//
//  TaxfreeCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/30/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class TaxfreeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productHeaderLabel: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1
        let color = UIColor(red: 232.0/255, green: 232.0/255, blue: 232.0/255, alpha: 1.0)
        self.layer.borderColor = color.cgColor
        // Initialization code
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
    }
    
}
