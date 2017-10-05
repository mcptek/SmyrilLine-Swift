//
//  PlaceOrderTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/5/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class PlaceOrderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var orderPlaceButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.orderPlaceButton.layer.cornerRadius = 3
        self.orderPlaceButton.layer.masksToBounds = true
        self.orderPlaceButton.layer.cornerRadius = 3
        self.orderPlaceButton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
