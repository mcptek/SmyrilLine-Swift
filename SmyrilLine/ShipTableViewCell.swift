//
//  ShipTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 30/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class ShipTableViewCell: UITableViewCell {

    
    @IBOutlet weak var shipCollectionview: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
