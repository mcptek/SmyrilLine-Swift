//
//  InternetConnectivity.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/3/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

