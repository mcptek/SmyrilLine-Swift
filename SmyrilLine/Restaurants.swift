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

class RestaurantDetailsInfo: Mappable{
     var name : String?
     var imageUrl : String?
     var breakfastTime : String?
     var lunchTime : String?
     var dinnerTime : String?
     var restaurantDescription : String?
     var adultMeals : [AdultMealType]?
     var childrenMeals : [ChildMealType]?
     var breakfastItems : [ObjectSample]?
     var lunchItems : [ObjectSample]?
     var dinnerItems : [ObjectSample]?
    var attatchFileUrl: String?
    var attatchFileName: String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        breakfastTime <- map["breakfastTime"]
        lunchTime <- map["lunchTime"]
        dinnerTime <- map["dinnerTime"]
        restaurantDescription <- map["description"]
        breakfastItems <- map["breakfastItems"]
        lunchItems <- map["lunchItems"]
        dinnerItems <- map["dinnerItems"]
        adultMeals <- map["meals"]
        childrenMeals <- map["meals"]
        attatchFileUrl <- map["attachedFileUrl"]
        attatchFileName <- map["attachedFileName"]
    }
}

class AdultMealType: Mappable{
    var name : String?
    var prebookPrice : String?
    var onboardPrice : String?
    var description : String?
    var save : String?
    var time : String?
    var seatingTime : String?
    var timeNote : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        prebookPrice <- map["adultPrebookPrice"]
        onboardPrice <- map["adultOnboardPrice"]
        description <- map["description"]
        save <- map["adultSave"]
        time <- map["time"]
        seatingTime <- map["seatingTime"]
        timeNote <- map["seatingText"]
    }
}

class ChildMealType: Mappable{
    var name : String?
    var prebookPrice : String?
    var onboardPrice : String?
    var description : String?
    var save : String?
    var time : String?
    var seatingTime : String?
    var timeNote : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        prebookPrice <- map["childPrebookPrice"]
        onboardPrice <- map["childOnboardPrice"]
        description <- map["description"]
        save <- map["childSave"]
        time <- map["time"]
        seatingTime <- map["seatingTime"]
        timeNote <- map["seatingText"]
    }
}

class ObjectSample: Mappable{
    var name : String?
    var imageUrl : String?
    var price : String?
    var description : String?
    var objectId : String?
    var attatchFileUrl: String?
    var attatchFileName: String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        price <- map["price"]
        description <- map["description"]
        objectId <- map["id"]
        attatchFileUrl <- map["attachedFileUrl"]
        attatchFileName <- map["attachedFileName"]
    }
}
