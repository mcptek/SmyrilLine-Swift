//
//  MessageObject.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/14/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class Message {
    let messageTitle: String?
    let messageDetails: String?
    let messageUrlStr: String?
    let messageId: String?
    let messageStatus: NSNumber?
    let messageTime: Double?
    
    init(title: String, details: String, imageUrl: String, idOfdMessage: String, status: NSNumber, time: Double) {
        self.messageId = idOfdMessage
        self.messageTitle = title
        self.messageDetails = details
        self.messageUrlStr = imageUrl
        self.messageStatus = status
        self.messageTime = time
    }
}
