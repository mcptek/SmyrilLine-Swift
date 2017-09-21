//
//  SignalRConnection.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/13/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation
import SignalRSwift

class StreamingConnection{
    static let sharedInstance = StreamingConnection()
    let connection: HubConnection!
    let hub: HubProxy!
     init() {
        self.connection = HubConnection(withUrl: UrlMCP.server_base_url)
        self.hub = self.connection.createHubProxy(hubName: "mcp")
    }
}
