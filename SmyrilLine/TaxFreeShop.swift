//
//  TaxFreeShop.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/25/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import ObjectMapper

class TaxFreeShopInfo: Mappable{
    var shopName: String?
    var shopImageUrlStr: String?
    var shopOpeningClosingTime: String?
    var shopLocation: String?
    var itemArray : [ShopObject]?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        shopName <- map["name"]
        shopImageUrlStr <- map["imageUrl"]
        shopOpeningClosingTime <- map["openingHours"]
        shopLocation <- map["subheader"]
        itemArray <- map["children"]
    }
}

class ShopObject: Mappable{
    var name : String?
    var imageUrl : String?
    var objectId : String?
    var objectHeader : String?
    var objectPrice : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        objectId <- map["id"]
        objectHeader <- map["description"]
        objectPrice <- map["price"]
    }
}
