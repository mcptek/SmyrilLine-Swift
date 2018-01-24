//
//  RouteTableViewCell.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    
    @IBOutlet weak var routeCollectionview: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
