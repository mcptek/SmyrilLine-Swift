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
    var shopDescription: String?
    var shopImageUrlStr: String?
    var shopOpeningClosingTime: String?
    var shopLocation: String?
    var itemArray : [ShopObject]?
    var attatchFileName: String?
    var attatchFileUrl: String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        shopName <- map["name"]
        shopDescription <- map["description"]
        shopImageUrlStr <- map["imageUrl"]
        shopOpeningClosingTime <- map["openingHours"]
        shopLocation <- map["subheader"]
        itemArray <- map["children"]
        attatchFileName <- map["attachedFileName"]
        attatchFileUrl <- map["attachedFileUrl"]
    }
}

class ShopObject: Mappable{
    var name : String?
    var shopTitle: String?
    var imageUrl : String?
    var objectId : String?
    var objectHeader : String?
    var objectPrice : String?
    var attatchFileUrl: String?
    var attatchFileName: String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        shopTitle <- map["title"]
        imageUrl <- map["imageUrl"]
        objectId <- map["id"]
        objectHeader <- map["description"]
        objectPrice <- map["price"]
        attatchFileUrl <- map["attachedFileUrl"]
        attatchFileName <- map["attachedFileName"]
    }
}
