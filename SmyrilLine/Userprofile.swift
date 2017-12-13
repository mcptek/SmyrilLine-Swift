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
    var imageUrl : String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        imageUrl <- map["imageUrl"]
    }
}
