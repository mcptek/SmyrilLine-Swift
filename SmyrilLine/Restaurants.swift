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
     var adultMeals : [MealType]?
     var childrenMeals : [MealType]?
     var breakfastItems : [ObjectSample]?
     var lunchItems : [ObjectSample]?
     var dinnerItems : [ObjectSample]?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        breakfastTime <- map["breakfastTime"]
        lunchTime <- map["lunchTime"]
        dinnerTime <- map["dinnerTime"]
        restaurantDescription <- map["openCloseTimeText"]
        breakfastItems <- map["breakfastItems"]
        lunchItems <- map["lunchItems"]
        dinnerItems <- map["dinnerItems"]
        adultMeals <- map["adultMeals"]
        childrenMeals <- map["childrenMeals"]
    }
}

class MealType: Mappable{
    var name : String?
    var prebookPrice : String?
    var onboardPrice : String?
    var description : String?
    var save : String?
    var time : String?
    var timeNote : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        prebookPrice <- map["prebookPrice"]
        onboardPrice <- map["onboardPrice"]
        description <- map["tag"]
        save <- map["save"]
        time <- map["time"]
        timeNote <- map["seatingText"]
    }
}

class ObjectSample: Mappable{
    var name : String?
    var imageUrl : String?
    var price : String?
    var description : String?
    var objectId : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        price <- map["subheader"]
        description <- map["header"]
        objectId <- map["id"]
    }
}
