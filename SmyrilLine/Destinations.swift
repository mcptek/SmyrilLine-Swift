//
//  Destinations.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/24/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import ObjectMapper

class DestinationInfo: Mappable{
    var itemArray : [DestinationChildren]?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        itemArray <- map["children"]
    }
}

class DestinationChildren: Mappable{
    var childrenId : String?
    var name : String?
    var imageUrl : String?
    var destinationDescription : String?
    var attatchFileName: String?
    var attatchFileUrl: String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        childrenId <- map["id"]
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        destinationDescription <- map["description"]
        attatchFileName <- map["attachedFileName"]
        attatchFileUrl <- map["attachedFileUrl"]
    }
}

class GeneralCategory: Mappable{
    var ObjectId : String?
    var name : String?
    var imageUrl : String?
    var detailsDescription : String?
    var attatchFileName: String?
    var attatchFileUrl: String?
    var itemArray : [DestinationChildren]?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        ObjectId <- map["id"]
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        detailsDescription <- map["description"]
        attatchFileName <- map["attachedFileName"]
        attatchFileUrl <- map["attachedFileUrl"]
        itemArray <- map["children"]
    }
}
