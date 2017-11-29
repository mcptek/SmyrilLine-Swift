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
    static let WebSocket_url = "ws://109.74.192.138:82/ws/"
    static let quedBulletinPath = "/api/Schedule/FindQueuedBulletin"
    static let shipServerPath = "http://smy-wp.mcp.com"
    static let shiptrackerInfo = "http://console.mcp.com/mtracking.php?ship=22"
    static let shipTrackerTilePath = "http://smy-wp.mcp.com/osm/raster-v8.json"
    static let shipTrackerTrajectoryPath = "http://console.mcp.com/mtrajectory.php?ship=22"
    static let restaurantParentPath = "/api/smyrilline/restaurants"
    static let destinationParentPath = "/api/smyrilline/destinations"
    static let taxFreeShopParentPath = "/api/smyrilline/taxfreeshop"
    static let ShipInfoParentPath = "/api/smyrilline/shipinfo"
    
}
