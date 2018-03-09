//
//  ReachabilityManager.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/19/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ReachabilityManager: NSObject {
    static  let shared = ReachabilityManager()
        // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .notReachable
    }
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    // 5. Reachability instance for Network status monitoring
    let reachability = Reachability()!
    
    /// Called whenever there is a change in NetworkReachibility Status
    ///
    /// — parameter notification: Notification with the Reachability instance
    func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
            StreamingConnection.sharedInstance.connection.stop()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: reachability)
        case .reachableViaWiFi:
            debugPrint("Network reachable through WiFi")
            if StreamingConnection.sharedInstance.connection.state == .disconnected
            {
                StreamingConnection.sharedInstance.connection.start()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: reachability)
        case .reachableViaWWAN:
            debugPrint("Network reachable through Cellular Data")
            if StreamingConnection.sharedInstance.connection.state == .disconnected
            {
                StreamingConnection.sharedInstance.connection.start()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: reachability)
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
}
