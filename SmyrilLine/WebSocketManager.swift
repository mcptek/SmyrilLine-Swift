//
//  WebSocketManager.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/23/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import Starscream
import Device_swift


class WebSocketSharedManager {
    // Declare class instance property
    static let sharedInstance = WebSocketSharedManager()
    
    var socket: WebSocket?
    
    private init() {
       self.socket =  WebSocket(url: URL(string: UrlMCP.WebSocket_url + "?deviceId=" + (UIDevice.current.identifierForVendor?.uuidString)!)!, protocols: ["chat", "superchat"])
    }
    
}
