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
    //let hubConnection = HubConnection(withUrl: UrlMCP.signalRStreamingCoonection)
    //let hub = Hubpro //hubConnection.createHubProxy(hubName: "mcp")
     init() {
        self.connection = HubConnection(withUrl: UrlMCP.signalRStreamingCoonection)
        self.hub = self.connection.createHubProxy(hubName: "mcp")
//        self.connection = HubConnection(withUrl: UrlMCP.signalRStreamingCoonection)
//        var chat = hubConnection.createHubProxy(hubName: "mcp")
    }
}

//let sharedNetworkManager = NetworkManager(baseURL: API.baseURL)

//final class StreamingConnection {
//    
//    // MARK: - Properties
//    static let sharedInstance = StreamingConnection(baseURL: <#URL#>)
//    let connectionURL: String
//    let chatHub: Hub!
//    let connection: SignalR!
//    // Initialization
//    
//    init(baseURL: URL) {
//        self.connection = SignalR(self.connectionURL)
//        self.chatHub = Hub("mcp")
//        self.connection.addHub(self.chatHub)
//    }
//    
//}
