//
//  ChatMessageModel.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/22/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import ObjectMapper

class ChatMessageMOdel: NSObject {
    var message: String
    var messageType: Int
    var status: Int
    var time: String
    
    init(message: String, messageType: Int, time: String, status: Int) {
        self.message = message
        self.messageType = messageType
        self.status = status
        self.time = time
    }
}


