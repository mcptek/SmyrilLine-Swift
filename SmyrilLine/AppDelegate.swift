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
import SwiftyJSON
import UserNotifications
import ReachabilitySwift

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Added swift file
        self.createSocketConnection()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        return true
    }
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

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
            print("Connected")
            let language = "en"
            let AppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let phoneType = "iPhone Demo"
            let phoneId = UIDevice.current.identifierForVendor?.uuidString
            let ageGroup = "All"
            let gender = "All"
            StreamingConnection.sharedInstance.hub.invoke(method: "register", withArgs: [phoneId ?? "1234",phoneType,AppVersion ?? "1.0",language,ageGroup,gender], completionHandler: { (result, error) in
            })
            
            StreamingConnection.sharedInstance.hub.on(eventName: "register") { (args) in
                print(args)
            }

            StreamingConnection.sharedInstance.hub.on(eventName: "onBulletinSent") { (myArray) in
                let dic = myArray[0] as? NSDictionary
                
                if let title = dic?.value(forKey: "title") as? String, let details = dic?.value(forKey: "description") as? String, let imageUrl = dic?.value(forKey: "image_url") as? String, let id = dic?.value(forKey: "id") as? String
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
                StreamingConnection.sharedInstance.connection.start()
            }
        }
        
        StreamingConnection.sharedInstance.connection.start()
        
    }
    
    func saveBulletin(title: String, message: String, imageUrlStr: String) {
        self.saveMeesageWith(messageId: self.retrieveMessageId(), messageTitle: title, messageDetails: message, imageUrlStr: imageUrlStr, UnixTime: NSDate().timeIntervalSince1970)
        
        let defaults = UserDefaults.standard
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let desiredDate = dateFormatter.string(from: date)
        defaults.set(desiredDate, forKey: "LastTime")

        if UIApplication.shared.applicationState == .active
        {
            let alert = UIAlertController(title: "Notification", message:title, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        let notification = UILocalNotification()
        notification.alertBody = title
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        StreamingConnection.sharedInstance.connection.stop()
        
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "LastTime") is String
        {
        }
        else
        {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
            let desiredDate = dateFormatter.string(from: date)
            defaults.set(desiredDate, forKey: "LastTime")

        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        StreamingConnection.sharedInstance.connection.start()
        
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
        
        // 3
        message.setValue(messageId, forKeyPath: "messageId")
        message.setValue(messageTitle, forKeyPath: "title")
        message.setValue(messageDetails, forKeyPath: "details")
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
            }
        }
        catch
        {
            print(error)
        }

    }

}

