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
    var name : [ObjectSample]?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        name <- map["children"]
    }
}
