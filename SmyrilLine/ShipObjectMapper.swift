//
//  ShipObjectMapper.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 30/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import Foundation
import ObjectMapper

class ShipObjectInfo: Mappable{
    var name: String?
    var shipId: String?
    var shipImageUrlStr: String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        shipId <- map["id"]
        shipImageUrlStr <- map["imageUrl"]
    }
}
