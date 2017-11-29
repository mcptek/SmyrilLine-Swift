//
//  Messaging.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/23/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import ObjectMapper

class Messaging: Mappable{
    var MessageType : Int?
    var userList : [User]?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        userList <- map["ParamList"]
        MessageType <- map["MessageType"]
    }
}

class User: Mappable{
    var deviceId : String?
     var bookingNo : Int?
     var name : String?
     var description : String?
     var imageUrl : String?
     var gender : String?
     var country : String?
     var lastSeen : Int64?
     var lastCommunication : Int64?
     var status : Int?
     var visibility : Int?
     var newMessageCount : Int?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        deviceId <- map["deviceId"]
        bookingNo <- map["bookingNo"]
        name <- map["name"]
        description <- map["description"]
        imageUrl <- map["imageUrl"]
        gender <- map["gender"]
        country <- map["country"]
        lastSeen <- map["lastSeen"]
        lastCommunication <- map["lastCommunication"]
        status <- map["status"]
        visibility <- map["visibility"]
        newMessageCount <- map["newMessageCount"]
    }
}
