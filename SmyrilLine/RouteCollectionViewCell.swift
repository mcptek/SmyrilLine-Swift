//
//  RouteCollectionViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 16/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.masksToBounds = true
        // corner radius
        self.layer.cornerRadius = 5
        
        // border
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        // shadow
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 3, height: 3)
//        self.layer.shadowOpacity = 0.1
//        self.layer.shadowRadius = 3.0
        
    }
}
