//
//  SmyrilLineUrl.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/24/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import Foundation

struct UrlMCP {
    static let server_base_url = "http://stage-smy-wp.mcp.com:82"
    static let Local_base_url = "http://192.168.1.208:5000"
    static let quedBulletinPath = "/api/Schedule/FindQueuedBulletin"
    static let shipServerPath = "http://smy-wp.mcp.com"
    static let shiptrackerInfo = "http://console.mcp.com/mtracking.php?ship=22"
    static let shipTrackerTilePath = "http://smy-wp.mcp.com/osm/raster-v8.json"
    static let shipTrackerTrajectoryPath = "http://console.mcp.com/mtrajectory.php?ship=22"
    static let restaurantParentPath = "/api/smyrilline/restaurants"
    static let destinationParentPath = "/api/smyrilline/destinations"
    static let taxFreeShopParentPath = "/api/smyrilline/taxfreeshop"
    static let ShipInfoParentPath = "/api/smyrilline/shipinfo"
    static let ShipChoosingParentPath = "/api/smyrilline/ships"
    
    static let AcknowledgeMessage = "/chat/api/v2/onClientAcknowledgeMessage"
    static let SendMessageToServer = "/chat/api/v2/onChatMessageToServer"
    static let LoadMoreFromSender = "/chat/api/v2/LoadMoreFromSender"
    static let WebSocketConnectionStageurl = "ws://stage-smy-wp.mcp.com:8080/ws/"
    static let WebSocketLocalurl = "ws://192.168.1.47:5000/ws/"
    static let WebSocketProfilePicImageUpload = "/chat/api/v2/profileupdate"
    static let WebSocketGetUserList = "/chat/api/v2/GetCurrentUserList"
    static let WebSocketGetPendingChatMessage = "/chat/api/v2/FetchUndeliveredMessage?"
}
