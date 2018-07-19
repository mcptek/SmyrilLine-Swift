//
//  UserChat.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 20/6/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import Foundation

class Chat {
    var message : String
    var messageId : String
    var sendTime :  String//Double
    var userImageUrlString : String
    var type: MessageSendingStatus
    var fromLocalClient : Bool
    
    enum MessageSendingStatus: Int{
        case none = 100
        case sending = 0
        case sent = 1
        case delevered = 2
        case seen = 3
        case failed = 4
    }

    
    init(message : String, messageid : String, time: String, imageString: String, fromLocalClient: Bool, messageStatus: MessageSendingStatus) {
        self.message = message
        self.sendTime = time
        self.userImageUrlString = imageString
        self.fromLocalClient = fromLocalClient
        self.messageId = messageid
        self.type = messageStatus
    }
}
