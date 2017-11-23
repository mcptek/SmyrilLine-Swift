//
//  MessageType.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/22/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MessageSignature: NSObject {
    var MessageType: Int
    var Param: Any
    
    init(type: Int, list: Any) {
        self.MessageType = type
        self.Param = list
    }
}
