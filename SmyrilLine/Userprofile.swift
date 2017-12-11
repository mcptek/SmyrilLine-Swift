//
//  Userprofile.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/8/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import ObjectMapper

class UserProfile: Mappable{
    var name : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["name"]
    }
}
