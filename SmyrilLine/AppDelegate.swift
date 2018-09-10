//
//  AppDelegate.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/22/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import CoreData
import SignalRSwift
import Alamofire
import ObjectMapper
import SwiftyJSON
import UserNotifications
import ReachabilitySwift
import Device_swift
import IQKeyboardManagerSwift
import Starscream
import AudioToolbox.AudioServices

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,OnyxBeaconDelegate,WebSocketDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let SA_CLIENTID = "1f4654d91e78d061a0e00e6962e7de6bb5957276"
    let SA_SECRET  = "3c925c9c3e0040cf914a139355092ba972bd4a90"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Added swift file
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(red: 0.03, green: 0.54, blue: 0.84, alpha: 1.0)
        }
        UIApplication.shared.statusBarStyle = .lightContent
        
        if UserDefaults.standard.value(forKey: "CurrentSelectedLanguage") == nil
        {
            UserDefaults.standard.set(["en", "de", "fo", "da"], forKey: "AppleLanguages")
        }
        WebSocketSharedManager.sharedInstance.socket?.delegate = self
        WebSocketSharedManager.sharedInstance.socket?.connect()
        NewRelic.start(withApplicationToken:"AAc3ed7fc1d51b98bee31eafc0d5aa389bd9979495")
        self.createSocketConnection()
        self.setMessageLastTimeIfNotSet()
        self.checkIfThereIsAnyPendingNotificatio()
       // self.checkIfThereIsAnyPendingChatMessage()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("granted: (\(granted)")
        }
        UNUserNotificationCenter.current().delegate = self
        ReachabilityManager.shared.startMonitoring()
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 0.0
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        let onyxBeacon = OnyxBeacon.sharedInstance()
        onyxBeacon?.requestAlwaysAuthorization()
        onyxBeacon?.startService(withClientID: SA_CLIENTID, secret:SA_SECRET)
        onyxBeacon?.delegate = self
        
        return true
    }
    
    func onyxBeaconError(_ error: Error!) {
        print("Error: \(error) ");
    }

    // called when user interacts with notification (app not running in foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "chat" {
            print("handling notifications with the TestIdentifier Identifier")
            if let wd = UIApplication.shared.delegate?.window {
                if let tbCntlr = wd?.rootViewController as? UITabBarController {
                    tbCntlr.selectedIndex = 3
                }
            }
        }
        else {
            print("handling notifications with the TestIdentifier Identifier")
            if let wd = UIApplication.shared.delegate?.window {
                if let tbCntlr = wd?.rootViewController as? UITabBarController {
                    tbCntlr.selectedIndex = 4
                }
            }
        }
        
        completionHandler()
        
    }
    
    // called if app is running in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
        notification: UNNotification, withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // show alert while app is running in foreground
        return completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func checkIfThereIsAnyPendingChatMessage() {
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let urlStr = UrlMCP.server_base_url + UrlMCP.WebSocketGetPendingChatMessage + "receiverId=" + (UIDevice.current.identifierForVendor?.uuidString)!
        
        Alamofire.request(urlStr, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers)
            .responseArray { (response: DataResponse<[UserChatMessage]>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        if let array = response.result.value {
                            var messageId = ""
                            for object in array {
                                if let title = object.message, let idMessage = object.messageId {
                                    self.createLocalNotification(messageTitle: title)
                                    if messageId.count > 0
                                    {
                                        messageId += ",\( String(describing: idMessage))"
                                    }
                                    else
                                    {
                                        messageId = String(describing: idMessage)
                                    }
                                }
                            }
                            if messageId.count > 0 {
                                let params: Parameters = [
                                    "msgIds": messageId
                                ]
                                
                                let url = UrlMCP.server_base_url + UrlMCP.WebSocketAcknowledgeMultipleMessageForBackground
                                Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                                    print(response.response?.statusCode ?? "no status code")
                                    if response.response?.statusCode == 200 {
                                        print("Sent")
                                    }
                                }
                            }
                        }
                    }
                case .failure( _):
                    print(response.result.error!)
                }
        }
    }
    
    
    func checkIfThereIsAnyPendingNotificatio()  {
        let time = UserDefaults.standard.value(forKey: "LastTime") as! String
        let clientId =  UIDevice.current.identifierForVendor?.uuidString
        let params: Parameters = [
            "startTime": time,
            "clientid": clientId!
        ]
        
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.quedBulletinPath, method:.post, parameters: params, encoding: URLEncoding.httpBody, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    
                    if response.response?.statusCode == 200
                    {
                        
                        if let json = response.result.value as? [Any]
                        {
                            var messageId = ""
                            for object in json
                            {
                                let dic = object as? NSDictionary
                                
                                if let title = dic?.value(forKey: "title") as? String, let details = dic?.value(forKey: "description") as? String, let imageUrl = dic?.value(forKey: "image_url") as? String
                                {
                                    self.saveBulletin(title: title, message: details, imageUrlStr: imageUrl)
                                }
                                
                                if let id = dic?.value(forKey: "id") as? NSNumber
                                {
                                    if messageId.characters.count > 0
                                    {
                                        messageId += ",\( String(describing: id))"
                                    }
                                    else
                                    {
                                        messageId = String(describing: id)
                                    }
                                }
                            }
                            
                            if messageId.characters.count > 0
                            {
                                let bulletinAcknowledgementUrl = String(format: "/api/Schedule/AckQueuedBulletin?scheduleId=%@&clientId=%@", messageId, clientId!)
                                print(UrlMCP.server_base_url + bulletinAcknowledgementUrl)
                                Alamofire.request(UrlMCP.server_base_url + bulletinAcknowledgementUrl, method:.get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil)
                                    .responseJSON { (response) in
                                        switch response.result {
                                        case .success:
                                            print("success")
                                        case .failure(_):
                                            print(response.result.error?.localizedDescription ?? "Default warning!!")
                                        }
                                }
                            }
                        }
                    }
                case .failure( _):
                    print(response.result.error!)
                }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        self.checkIfThereIsAnyPendingChatMessage()
        
        let time = UserDefaults.standard.value(forKey: "LastTime") as! String
        let clientId =  UIDevice.current.identifierForVendor?.uuidString
        let params: Parameters = [
            "startTime": time,
            "clientid": clientId!
        ]
        
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.quedBulletinPath, method:.post, parameters: params, encoding: URLEncoding.httpBody, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    
                    if response.response?.statusCode == 200
                    {
                        
                        if let json = response.result.value as? [Any]
                        {
                            var messageId = ""
                            for object in json
                            {
                                let dic = object as? NSDictionary
                                
                                if let title = dic?.value(forKey: "title") as? String, let details = dic?.value(forKey: "description") as? String, let imageUrl = dic?.value(forKey: "image_url") as? String
                                {
                                    self.saveBulletin(title: title, message: details, imageUrlStr: imageUrl)
                                }
                                
                                if let id = dic?.value(forKey: "id") as? NSNumber
                                {
                                    if messageId.characters.count > 0
                                    {
                                        messageId += ",\( String(describing: id))"
                                    }
                                    else
                                    {
                                        messageId = String(describing: id)
                                    }
                                }
                            }
                            
                            if messageId.characters.count > 0
                            {
                                let bulletinAcknowledgementUrl = String(format: "/api/Schedule/AckQueuedBulletin?scheduleId=%@&clientId=%@", messageId, clientId!)
                                print(UrlMCP.server_base_url + bulletinAcknowledgementUrl)
                                Alamofire.request(UrlMCP.server_base_url + bulletinAcknowledgementUrl, method:.get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil)
                                    .responseJSON { (response) in
                                        switch response.result {
                                        case .success:
                                            print("success")
                                            completionHandler(.newData)
                                        case .failure(_):
                                            print(response.result.error?.localizedDescription ?? "Default warning!!")
                                            completionHandler(.newData)
                                        }
                                }
                            }
                        }
                    }
                case .failure( _):
                    print(response.result.error!)
                    completionHandler(.failed)
                }
        }
    }
    
    func createSocketConnection()  {
        StreamingConnection.sharedInstance.connection.started = {
            var language = "en"
            if UserDefaults.standard.value(forKey: "CurrentSelectedLanguage") != nil {
                let settingsLanguage = UserDefaults.standard.value(forKey: "CurrentSelectedLanguage")  as! Int
                switch settingsLanguage {
                case 0:
                    language = "en"
                case 1:
                    language = "de"
                case 2:
                    language = "fo"
                default:
                   language = "da"
                }
            }
            
            let AppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let phoneType = UIDevice.current.deviceType
            let phoneId = UIDevice.current.identifierForVendor?.uuidString
            let ageGroup = UserDefaults.standard.value(forKey: "ageSettings")
            let gender = UserDefaults.standard.value(forKey: "genderSettings")
            StreamingConnection.sharedInstance.hub.invoke(method: "register", withArgs: [phoneId ?? "1234",String(describing: phoneType),AppVersion ?? "1.0",language,ageGroup ?? "all",gender ?? "both"], completionHandler: { (result, error) in
            })
            
            StreamingConnection.sharedInstance.hub.on(eventName: "register") { (args) in
                print(args)
            }

            StreamingConnection.sharedInstance.hub.on(eventName: "onBulletinSent") { (myArray) in
                let dic = myArray[0] as? NSDictionary
                if let title = dic?.value(forKey: "title") as? String, let details = dic?.value(forKey: "description") as? String, let imageUrl = dic?.value(forKey: "image_url") as? String, let id = dic?.value(forKey: "id") as? NSNumber
                {
                    self.saveBulletin(title: title, message: details, imageUrlStr: imageUrl)
                    StreamingConnection.sharedInstance.hub.invoke(method: "BulletinAck", withArgs: [id, phoneId ?? "1234"])
                }
            }
        }
        
        StreamingConnection.sharedInstance.connection.reconnecting = {
            print("Reconnecting...")
        }
        
        StreamingConnection.sharedInstance.connection.reconnected = {
            print("Reconnected.")
        }
        
        StreamingConnection.sharedInstance.connection.closed = {
            print("Disconnected")
        }
        
        StreamingConnection.sharedInstance.connection.connectionSlow = {
            print("Connection slow...")
        }
        
        StreamingConnection.sharedInstance.connection.error = { error in
            print(error.localizedDescription)
            if UIApplication.shared.applicationState == .active
            {
                StreamingConnection.sharedInstance.connection.stop()
                self.createSocketConnection()
                //StreamingConnection.sharedInstance.connection.start()
            }
        }
        
        StreamingConnection.sharedInstance.connection.start()
        
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let arr: Array<Messaging> = Mapper<Messaging>().mapArray(JSONString: text) {
            if let userType = arr[0].MessageType {
                switch(userType) {
                case 5,2:  // retrieve chat user list
                    if let UserList = arr[0].userList {
                        NotificationCenter.default.post(name: NSNotification.Name("UpdateChatUserList"), object: self, userInfo: ["UserList": UserList])
                    }
                case 3: //retrieve sent message acknowledgement status and update it in tableview
                    if let acknowledgementStatusDic = arr[0].Message {
                        NotificationCenter.default.post(name: NSNotification.Name("UpdateSentMessageAcknowledgementStatus"), object: self, userInfo: ["Acknowledgement": acknowledgementStatusDic])
                    }
                case 8: // receive message and take proper action
                    // send acknowledgement based on seen or delivered
                    let value = self.checkIsChatContainerCurrentViewController()
                    self.callAcknowledgeMessageWebserviceForMessageId(messageId: arr[0].Message?["messageId"] as! String, withMessageStatus: value)
                    if value == 3 { // inside chat, so status will be seen
                        if let dic = arr[0].Message {
                            NotificationCenter.default.post(name: NSNotification.Name("InsertNewMessage"), object: self, userInfo: ["newMessage": dic])
                        }
                    }
                    else { // outside chat, so status will be delivered
                        if let dic = arr[0].Message?["senderChatUserServerModel"] as? [String: Any] {
                            NotificationCenter.default.post(name: NSNotification.Name("UpdateMessageCountList"), object: self, userInfo: ["senderChatUserServerModel": dic])
                        }
                        //if let title = arr[0].Message?["messageBase64"] as? String {
                            //self.createLocalNotification(messageTitle: title)
                       // }
                    }
                case 9:
                    // Receive group chat message
                    if let dic = arr[0].Message {
                        NotificationCenter.default.post(name: NSNotification.Name("InsertNewMessageForGroup"), object: self, userInfo: ["newMessage": dic])
                    }
                case 10:
                    if let dic = arr[0].Message {
                        if self.checkIsAllGroupListShowingIsCurrentViewController() {
                            NotificationCenter.default.post(name: NSNotification.Name("groupCreated"), object: self, userInfo: ["newMessage": dic])
                        }
                        else {
                            NotificationCenter.default.post(name: NSNotification.Name("groupUpdated"), object: self, userInfo: ["newMessage": dic])
                        }
                    }
                case 11:
                    if let allGroups = arr[0].groupList {
                        NotificationCenter.default.post(name: NSNotification.Name("groupDeleted"), object: self, userInfo: ["newMessage": allGroups])
                    }
                default:
                    print("Default")
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func createLocalNotification(messageTitle: String)  {
//        let notification = UILocalNotification()
//        notification.alertBody = messageTitle.base64Decoded()
//        notification.soundName = UILocalNotificationDefaultSoundName
//        UIApplication.shared.scheduleLocalNotification(notification)
//        //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
        
        let content = UNMutableNotificationContent()
        content.title = messageTitle.base64Decoded()!
        //content.body = nil
        content.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "chat", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func checkIsChatContainerCurrentViewController() -> Int {
        var flag = 2
        if let wd = UIApplication.shared.delegate?.window {
            if let tabbarController = wd?.rootViewController as? UITabBarController {
                if let navigationCntlr = tabbarController.selectedViewController as? UINavigationController {
                    if navigationCntlr.topViewController is ChatContainerViewController {
                        flag = 3
                    }
                    else {
                        flag = 2
                    }
                }
            }
        }
        return flag
    }
    
    func checkIsGroupChatContainerCurrentViewController() -> Bool {
        if let wd = UIApplication.shared.delegate?.window {
            if let tabbarController = wd?.rootViewController as? UITabBarController {
                if let navigationCntlr = tabbarController.selectedViewController as? UINavigationController {
                    if navigationCntlr.topViewController is GroupChatContainerViewController {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func checkIsAllGroupListShowingIsCurrentViewController() -> Bool {
        if let wd = UIApplication.shared.delegate?.window {
            if let tabbarController = wd?.rootViewController as? UITabBarController {
                if let navigationCntlr = tabbarController.selectedViewController as? UINavigationController {
                    if navigationCntlr.topViewController is InboxViewController {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func callAcknowledgeMessageWebserviceForMessageId(messageId: String, withMessageStatus status:Int) {
        //let messageSendingStatus = 3
        let params: Parameters = [
            "messageId": messageId,
            "messageSendingStatus": status,
            ]
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = UrlMCP.server_base_url + UrlMCP.AcknowledgeMessage
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            print(response.response?.statusCode ?? "no status code")
            if response.response?.statusCode == 200 {
                print("Sent")
            }
        }
    }
    
    
    
    func saveBulletin(title: String, message: String, imageUrlStr: String) {
        self.saveMeesageWith(messageId: self.retrieveMessageId(), messageTitle: title, messageDetails: message, imageUrlStr: imageUrlStr, UnixTime: NSDate().timeIntervalSince1970)
        
        let defaults = UserDefaults.standard
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let desiredDate = dateFormatter.string(from: date)
        defaults.set(desiredDate, forKey: "LastTime")

        if UIApplication.shared.applicationState == .active
        {
            let alert = UIAlertController(title: "Notification", message:title.decodeChatString(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        let notification = UILocalNotification()
        notification.alertBody = title.decodeChatString()
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func setMessageLastTimeIfNotSet()  {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "LastTime") is String
        {
        }
        else
        {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let desiredDate = dateFormatter.string(from: date)
            defaults.set(desiredDate, forKey: "LastTime")
            
        }
    }
    
    func uploadProfileVisibilitywithStatus(status:Int)  {
        let url = UrlMCP.server_base_url + UrlMCP.WebSocketProfilePicImageUpload
        
        Alamofire.request(url, method:.post, parameters:self.retrieveUserProfileDetailsforStatus(profileStatus: status), headers:nil).responseObject { (response: DataResponse<UserProfile>) in
            switch response.result {
            case .success:
                print("Status update success")
            case .failure( _):
                print("Status update failed")
            }
        }
    }
    
    func retrieveUserProfileDetailsforStatus(profileStatus: Int) -> [String: Any] {
        
        var imageUrl = String()
        if let url = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String {
            imageUrl = url
        }
        else {
            imageUrl = ""
        }
        
        var userName = ""
        if let profileUserName = UserDefaults.standard.value(forKey: "userName") as? String {
            userName = profileUserName
        }
        else {
            userName = ""
        }
        
        var introInfo = ""
        if let profileUserIntroInfo = UserDefaults.standard.value(forKey: "introInfo") as? String {
            introInfo = profileUserIntroInfo
        }
        else {
            introInfo = ""
        }
        
        var visibilityStatus = 2
        if let status = UserDefaults.standard.value(forKey: "userVisibilityStatus") as? String {
            if status == "Visible to booking" {
                visibilityStatus = 1
            }
            else if status == "Invisible" {
                visibilityStatus = 3
            }
        }
        
        let bookingNumber = 123456
        let status = profileStatus
        
        
        let params: Parameters = [
            "bookingNo": bookingNumber,
            "Name": userName,
            "description": introInfo,
            "imageUrl": imageUrl,
            "country": "Bangladesh",
            "deviceId": (UIDevice.current.identifierForVendor?.uuidString)!,
            "gender": "Male",
            "status": status,
            "visibility": visibilityStatus,
            "imageBase64": "",
            "phoneType": "iOS",
            ]
        return params
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        OnyxBeacon.sharedInstance().appWillResignActive()
        ReachabilityManager.shared.stopMonitoring()
        StreamingConnection.sharedInstance.connection.stop()
        //WebSocketSharedManager.sharedInstance.socket?.disconnect()
        self.setMessageLastTimeIfNotSet()
        if UserDefaults.standard.bool(forKey: "GuideScreen") == true {
            self.uploadProfileVisibilitywithStatus(status: 0)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if UserDefaults.standard.bool(forKey: "GuideScreen") == true {
            self.uploadProfileVisibilitywithStatus(status: 1)
        }
        
        OnyxBeacon.sharedInstance().willEnterForeground()
        ReachabilityManager.shared.startMonitoring()
        StreamingConnection.sharedInstance.connection.start()
        WebSocketSharedManager.sharedInstance.socket?.connect()
        self.setMessageLastTimeIfNotSet()
        let time = UserDefaults.standard.value(forKey: "LastTime") as! String
        let clientId =  UIDevice.current.identifierForVendor?.uuidString
        let params: Parameters = [
            "startTime": time,
            "clientid": clientId!
        ]
        
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.quedBulletinPath, method:.post, parameters: params, encoding: URLEncoding.httpBody, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    
                    if response.response?.statusCode == 200
                    {
                        
                        if let json = response.result.value as? [Any]
                        {
                            var messageId = ""
                            for object in json
                            {
                                let dic = object as? NSDictionary
                                
                                if let title = dic?.value(forKey: "title") as? String, let details = dic?.value(forKey: "description") as? String, let imageUrl = dic?.value(forKey: "image_url") as? String
                                {
                                    self.saveBulletin(title: title, message: details, imageUrlStr: imageUrl)
                                }
                                
                                if let id = dic?.value(forKey: "id") as? NSNumber
                                {
                                    if messageId.count > 0
                                    {
                                        messageId += ",\( String(describing: id))"
                                    }
                                    else
                                    {
                                        messageId = String(describing: id)
                                    }
                                }
                            }
                            
                            if messageId.count > 0
                            {
                                let bulletinAcknowledgementUrl = String(format: "/api/Schedule/AckQueuedBulletin?scheduleId=%@&clientId=%@", messageId, clientId!)
                                print(UrlMCP.server_base_url + bulletinAcknowledgementUrl)
                                Alamofire.request(UrlMCP.server_base_url + bulletinAcknowledgementUrl, method:.get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil)
                                    .responseJSON { (response) in
                                        switch response.result {
                                        case .success:
                                            print("success")
                                        case .failure(_):
                                            print(response.result.error?.localizedDescription ?? "Default warning!!")
                                        }
                                }
                            }
                        }
                    }
                case .failure( _):
                    print(response.result.error!)
                }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SmyrilLine")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func retrieveMessageId() -> String {
        let managedContext =
            self.persistentContainer.viewContext
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Inbox")
        do {
            let messsageObject = try managedContext.fetch(fetchRequest)
            var messageId = 0
            if messsageObject.count > 0
            {
                for object in messsageObject
                {
                    let tempId = object.value(forKey: "messageId") as! String
                    if Int(tempId)! > messageId
                    {
                        messageId = Int(tempId)!
                    }
                }
                return String(messageId + 1)
            }
            else
            {
                return "1"
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return "1"
        }
    }
    
    func saveMeesageWith(messageId: String, messageTitle: String, messageDetails: String, imageUrlStr: String, UnixTime: Double)  {
        let managedContext =
            self.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Inbox", in: managedContext)!
        
        let message = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        let emojiEnabledMessageTitle = messageTitle.decodeChatString()
        let emojiEnabledMessageDetails = messageDetails.decodeChatString()
        
        
        // 3
        message.setValue(messageId, forKeyPath: "messageId")
        message.setValue(emojiEnabledMessageTitle, forKeyPath: "title")
        message.setValue(emojiEnabledMessageDetails, forKeyPath: "details")
        message.setValue(imageUrlStr, forKeyPath: "imageUrlStr")
        message.setValue(UnixTime, forKeyPath: "time")
        message.setValue(NSNumber(value: false), forKeyPath: "status")
        
        // 4
        do {
            try managedContext.save()
            // Define identifier
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("InboxNotification"), object: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveTotalUnreadMessage() -> Int {
        let managedContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Inbox")
        var totalUnreadMessages = 0
        do {
            let messsageObject = try managedContext.fetch(fetchRequest)
            for object in messsageObject
            {
                let isMessageRead = object.value(forKey: "status") as! NSNumber
                if isMessageRead == NSNumber(value: false)
                {
                    totalUnreadMessages += 1
                }
            }
            return totalUnreadMessages
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return 0
        }
    }
    
    func updateMessageStatusWithMessageId(messageId: String) {
        let managedContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Inbox")
        let predicate = NSPredicate(format: "messageId = '\(messageId)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] 
                objectUpdate.setValue(NSNumber(value: true), forKeyPath: "status")
                do{
                    try managedContext.save()
                }
                catch
                {
                    print(error)
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    
    func retrieveAllInboxMessages() -> [Message]? {
        let managedContext =
            self.persistentContainer.viewContext
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Inbox")
//        var AllMessages: [Message]?
        var AllMessages:[Message] = []
        
        do {
            let messsageObject = try managedContext.fetch(fetchRequest)
            for object in messsageObject
            {
                let title = object.value(forKey: "title") as! String
                let details = object.value(forKey: "details") as! String
                let imageUrlStr = object.value(forKey: "imageUrlStr") as! String
                let messageId = object.value(forKey: "messageId") as! String
                let messageStatus = object.value(forKey: "status") as! NSNumber
                let time = object.value(forKey: "time") as! Double
                let object = Message.init(title: title, details: details, imageUrl: imageUrlStr, idOfdMessage: messageId, status: messageStatus, time: time)
                AllMessages.append(object)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return AllMessages.reversed()
    }
    
    func deleteMessageforMessageId(messageId: String)  {
        let managedContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Inbox")
        let predicate = NSPredicate(format: "messageId = '\(messageId)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectDelete = test[0]
                managedContext.delete(objectDelete)
                try managedContext.save()
            }
        }
        catch
        {
            print(error)
        }

    }

}

