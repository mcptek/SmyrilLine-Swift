//
//  Restaurants.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/24/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import ObjectMapper

class RestaurantInfo: Mappable{
    var name : [ObjectSample]?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["children"]
    }
}

class ObjectSample: Mappable{
    var name : String?
    var imageUrl : String?
    var objectId : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        objectId <- map["id"]
    }
}
