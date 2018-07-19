//
//  BookingMeal.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 18/7/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import Foundation

class Meal {
    var mealCount : String
    var mealDateStr : String
    var mealDate : TimeInterval
    var mealDescription :  String
    var type: MealStatus
    
    enum MealStatus: Int{
        case used = 0
        case unUsed = 1
    }
    
    init(count: String, dateStr: String, meadDatee: TimeInterval,  description: String, usedStatus:MealStatus) {
        self.mealCount = count
        self.mealDateStr = dateStr
        self.mealDate = meadDatee
        self.mealDescription = description
        self.type = usedStatus
    }
}
