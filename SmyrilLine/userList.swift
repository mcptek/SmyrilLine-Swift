//
//  RegisterChat.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/22/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class CurrentUserList: NSObject {
    var bookingNo: Int
    var name: String
    var profileDescription: String
    var imageUrl: String
    var country: String
    var deviceId: String
    var gender: String
    var status: Int
    var visibility: Int
    
    init(name: String, bookingNumber: Int, profileDescription: String, imageUrl: String, country: String, deviceId: String, gender: String, status: Int, visibility: Int ) {
        self.name = name
        self.bookingNo = bookingNumber
        self.profileDescription = profileDescription
        self.imageUrl = imageUrl
        self.country = country
        self.deviceId = deviceId
        self.gender = gender
        self.status = status
        self.visibility = visibility
    }
}
