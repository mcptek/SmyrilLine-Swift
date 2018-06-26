//
//  InboxViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/13/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import Starscream
import AlamofireObjectMapper
import Alamofire
import SwiftyJSON
import SDWebImage
import ObjectMapper

class InboxViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WebSocketDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var chatSearchBar: UISearchBar!
    var activityIndicatorView: UIActivityIndicatorView!
    var OnlineUserListArray = [User]()
    var filteredOnlineUserListArray = [User]()
    var RecentUserListArray = [User]()
    var filteredRecentUserListArray = [User]()
    var receiverDeviceId: String?
    var receiverProfileName: String?
    
    @IBOutlet weak var inboxTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Messaging"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        //let navigationBar = navigationController!.navigationBar
        //navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        
        self.inboxTableview.estimatedRowHeight = 150
        self.inboxTableview.rowHeight = UITableViewAutomaticDimension
        self.configureSearchBar()
        self.hideKeyboardWhenTappedAround()

        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChangedInMessaging), name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: nil)
        WebSocketSharedManager.sharedInstance.socket?.delegate = self
        if WebSocketSharedManager.sharedInstance.socket?.isConnected == false {
            WebSocketSharedManager.sharedInstance.socket?.connect()
        }
        else {
            self.RetrieveCurrentUserList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.chatSearchBar.resignFirstResponder()
//        self.newMessageReceived()
//        let nc = NotificationCenter.default
//        nc.addObserver(self, selector: #selector(newMessageReceived), name: Notification.Name("InboxNotification"), object: nil)
        self.navigationController?.navigationBar.isHidden = false
       // let navigationBar = navigationController!.navigationBar
       // navigationBar.attachToScrollView(self.inboxTableview)
        
        //let textFieldInsideSearchBar = self.chatSearchBar.value(forKey: "searchField") as? UITextField
        //textFieldInsideSearchBar?.textColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reachabilityChanged"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reachabilityChangedInMessaging() {
        if ReachabilityManager.shared.reachability.currentReachabilityStatus == .reachableViaWiFi {
            self.RetrieveCurrentUserList()
        }
    }
    
    func configureSearchBar()  {
        
        let color = UIColor(red: 51.0/255, green: 160.0/255, blue: 222.0/255, alpha: 1.0)
        //self.chatSearchBar.searchBarStyle = .minimal
        self.chatSearchBar.placeholder = "Search"
        self.chatSearchBar.setTextColor(color: .white)
        self.chatSearchBar.setTextFieldColor(color: color)
        self.chatSearchBar.setPlaceholderTextColor(color: .white)
        self.chatSearchBar.setSearchImageColor(color: .white)
        //self.chatSearchBar.setTextFieldClearButtonColor(color: .white)
        self.chatSearchBar.tintColor = UIColor.white
        self.chatSearchBar.subviews[0].subviews.flatMap(){ $0 as? UITextField }.first?.tintColor = UIColor.gray
        
        self.chatSearchBar.setImage(UIImage(), for: .clear, state: .normal)
        self.chatSearchBar.delegate = self

    }
    
    func retrieveUserProfileDetailsInfo() -> [String: Any] {
        
        var bookingNo = Int()
        if let bookingNumber = UserDefaults.standard.value(forKey: "bookingNumber") as? Int {
            bookingNo = bookingNumber
        }
        else {
            UserDefaults.standard.set(123456, forKey: "bookingNumber")
            bookingNo = 123456
        }
        
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
            if status == "Visible to boking" {
                visibilityStatus = 1
            }
            else if status == "Invisible" {
                visibilityStatus = 3
            }
        }
        
        let status = 1
        
        
        let params: Parameters = [
            "bookingNo": bookingNo,
            "Name": userName,
            "description": introInfo,
            "imageUrl": imageUrl,
            "country": "Bangladesh",
            "deviceId": (UIDevice.current.identifierForVendor?.uuidString)!,
            "gender": "Male",
            "status": status,
            "visibility": visibilityStatus,
            "phoneType": "iOS",
            ]
        return params
    }
    
    func RetrieveCurrentUserList() {
        self.OnlineUserListArray.removeAll()
        self.filteredOnlineUserListArray.removeAll()
        self.RecentUserListArray.removeAll()
        self.filteredRecentUserListArray.removeAll()
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let url = UrlMCP.server_base_url + UrlMCP.WebSocketGetUserList
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        Alamofire.request(url, method: .post, parameters: self.retrieveUserProfileDetailsInfo(), encoding: URLEncoding.default, headers: headers)
            .responseArray { (response: DataResponse<[User]>) in
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success:
                let forecastArray = response.result.value
                if let UserList = forecastArray {
                    self.filterChatUserList(UserList: UserList)
                }
                else {
                    self.showAlert(title: "Message", message: "No user list found")
                }
            case .failure(let error):
                self.showErrorAlert(error: error as NSError)
            }
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
        self.RetrieveCurrentUserList()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let arr: Array<Messaging> = Mapper<Messaging>().mapArray(JSONString: text) {
            print(arr[0].userList ?? "no user found")
            if let userType = arr[0].MessageType {
                switch(userType) {
                case 5,2:
                    if let UserList = arr[0].userList {
                        self.filterChatUserList(UserList: UserList)
                    }
                    else {
                        self.showAlert(title: "Message", message: "No user list found")
                    }
                case 8:
                    print(arr[0].Message ?? "default value")
                    self.callAcknowledgeMessageWebserviceForMessageId(messageId: arr[0].Message?["messageId"] as! String)
                    if let dic = arr[0].Message?["senderChatUserServerModel"] as? [String: Any] {
                        self.updateMessageCounterListforDeviceId(deviceId: (dic["deviceId"] as? String)!, lastCommunicationTime: (dic["lastCommunication"] as? Int64)!, lastSeenTime: (dic["lastSeen"] as? Int64)!)
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
    
    func updateMessageCounterListforDeviceId(deviceId: String, lastCommunicationTime:Int64, lastSeenTime:Int64)  {
        if self.filteredRecentUserListArray.contains(where: { $0.deviceId == deviceId }) {
            if let index = self.filteredRecentUserListArray.index(where: { $0.deviceId == deviceId }) {
                self.filteredRecentUserListArray[index].lastCommunication = lastCommunicationTime
                self.filteredRecentUserListArray[index].lastSeen = lastSeenTime
                if let count = self.filteredRecentUserListArray[index].newMessageCount {
                    self.filteredRecentUserListArray[index].newMessageCount = count + 1
                }
                else {
                    self.filteredRecentUserListArray[index].newMessageCount = 1
                }
            }
        }
        else if self.filteredOnlineUserListArray.contains(where: { $0.deviceId == deviceId }) {
            if let index = self.filteredOnlineUserListArray.index(where: { $0.deviceId == deviceId }) {
                self.filteredOnlineUserListArray[index].lastCommunication = lastCommunicationTime
                self.filteredOnlineUserListArray[index].lastSeen = lastSeenTime
                if let count = self.filteredOnlineUserListArray[index].newMessageCount {
                    self.filteredOnlineUserListArray[index].newMessageCount = count + 1
                }
                else {
                    self.filteredOnlineUserListArray[index].newMessageCount = 1
                }
            }
        }
        self.filteredRecentUserListArray = self.filteredRecentUserListArray.sorted(by: { $0.lastCommunication! > $1.lastCommunication! })
        self.filteredOnlineUserListArray = self.filteredOnlineUserListArray.sorted(by: { $0.lastCommunication! > $1.lastCommunication! })
        self.inboxTableview.reloadData()
    }
    
    
    
    func callAcknowledgeMessageWebserviceForMessageId(messageId: String) {
        let messageSendingStatus = 2
        let params: Parameters = [
            "messageId": messageId,
            "messageSendingStatus": messageSendingStatus,
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
    
    func filterChatUserList(UserList: [User] )  {
        
        self.OnlineUserListArray.removeAll()
        self.filteredOnlineUserListArray.removeAll()
        self.RecentUserListArray.removeAll()
        self.filteredRecentUserListArray.removeAll()
        
        for object in UserList {
            if let deviviceId = object.deviceId {
                if deviviceId == (UIDevice.current.identifierForVendor?.uuidString)! {
                    if let imageUrl = object.imageUrl {
                        UserDefaults.standard.set(imageUrl, forKey: "userProfileImageUrl")
                    }
                    if let userName = object.name {
                        UserDefaults.standard.set(userName, forKey: "userName")
                    }
                    if let intro = object.description {
                        UserDefaults.standard.set(intro, forKey: "introInfo")
                    }
                    continue
                }
            }
            
            if (object.visibility == 1 && object.bookingNo == 123456) || object.visibility == 2 {
                if object.lastCommunication! > 0 {
                    self.RecentUserListArray.append(object)
                    self.filteredRecentUserListArray.append(object)
                }
                else {
                    if object.status == 1 {
                        self.OnlineUserListArray.append(object)
                        self.filteredOnlineUserListArray.append(object)
                    }
                }
            }
        }
        self.filteredRecentUserListArray = self.filteredRecentUserListArray.sorted(by: { $0.lastCommunication! > $1.lastCommunication! })
        self.filteredOnlineUserListArray = self.filteredOnlineUserListArray.sorted(by: { $0.lastCommunication! > $1.lastCommunication! })
        self.inboxTableview.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "chatMessageCell" {
            let vc = segue.destination as! ChatContainerViewController
            if let senderId = UIDevice.current.identifierForVendor?.uuidString {
                vc.senderDeviceId = senderId
            }
            if let receiverId = self.receiverDeviceId {
                vc.receiverDeviceId = receiverId
            }
            
            if let name = self.receiverProfileName {
                vc.profileName = name.base64Decoded()
            }
        }
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filteredRecentUserListArray.removeAll()
        self.filteredOnlineUserListArray.removeAll()
        
        self.filteredRecentUserListArray = self.RecentUserListArray.filter({ (object: User) -> Bool in
            return (object.name?.base64Decoded()?.lowercased().range(of: searchText.lowercased()) != nil)
        })
        
        self.filteredOnlineUserListArray = self.OnlineUserListArray.filter({ (object: User) -> Bool in
            return (object.name?.base64Decoded()?.lowercased().range(of: searchText.lowercased()) != nil)
        })
        
        if searchText == "" {
            self.filteredRecentUserListArray.removeAll()
            self.filteredOnlineUserListArray.removeAll()
            self.filteredRecentUserListArray = self.RecentUserListArray
            self.filteredOnlineUserListArray = self.OnlineUserListArray
        }
        self.inboxTableview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.chatSearchBar.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var totalSection = 0
        if self.filteredRecentUserListArray.count > 0 {
            totalSection += 1
        }
        if self.filteredOnlineUserListArray.count > 0 {
            totalSection += 1
        }
        return totalSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath) as! ChatTableViewCell
        if indexPath.section == 0 && self.filteredRecentUserListArray.count > 0 {
            cell.statusHeaderLabel.text = "Recent"
            cell.userCollectionView.tag = 1010
        }
        else {
            cell.statusHeaderLabel.text = "Online"
            cell.userCollectionView.tag = 1011
        }
        cell.userCollectionView.reloadData()
        cell.userCollectionView.layoutIfNeeded()
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        
        return vw
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        
        return vw
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView.tag == 1010 {
            return self.filteredRecentUserListArray.count
        }
        else {
            return self.filteredOnlineUserListArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UserListCollectionViewCell
        if collectionView.tag == 1010 {
            cell.userNameLabel.backgroundColor = UIColor.clear
            cell.userNameLabel.textColor = UIColor.white
            cell.userImageView.backgroundColor = UIColor.white
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
            cell.userImageView.clipsToBounds = true
            cell.onlineTrackerImageView.isHidden = true
            if let status = self.filteredRecentUserListArray[indexPath.row].status {
                if status == 1 {
                    cell.onlineTrackerImageView.isHidden = false
                }
            }
            if let name = self.filteredRecentUserListArray[indexPath.row].name {
                if let decodedname = name.base64Decoded() {
                    cell.userNameLabel.text = decodedname
                }
                else {
                    cell.userNameLabel.text = name
                }
            }
            else {
                cell.userNameLabel.text = "No name Found"
            }
            
            if let imageUrlStr = self.filteredRecentUserListArray[indexPath.row].imageUrl
            {
                cell.userImageView.sd_setShowActivityIndicatorView(true)
                cell.userImageView.sd_setIndicatorStyle(.gray)
                cell.userImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: ""))
            }
            else {
                cell.userImageView.image = UIImage.init(named: "UserPlaceholder")
            }
            
            if let messageCount = self.filteredRecentUserListArray[indexPath.row].newMessageCount {
                if messageCount > 0 {
                    cell.unreadMessageLabel.isHidden = false
                    cell.unreadMessageLabel.text = String(messageCount)
                }
                else {
                    cell.unreadMessageLabel.isHidden = true
                }
            }
            else {
                cell.unreadMessageLabel.isHidden = true
            }
            
        }
        else {
            cell.userNameLabel.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
            cell.userImageView.backgroundColor = UIColor.white
            cell.userNameLabel.textColor = UIColor(red: 0.0/255, green: 135.0/255, blue: 215.0/255, alpha: 1.0)
            cell.userImageView.layer.cornerRadius = 0
            cell.userImageView.clipsToBounds = true
            cell.onlineTrackerImageView.isHidden = false
            if let name = self.filteredOnlineUserListArray[indexPath.row].name {
                if let decodedname = name.base64Decoded() {
                    cell.userNameLabel.text = decodedname
                }
                else {
                    cell.userNameLabel.text = name
                }
            }
            else {
                cell.userNameLabel.text = "No name Found"
            }
            
            if let imageUrlStr = self.filteredOnlineUserListArray[indexPath.row].imageUrl
            {
                cell.userImageView.sd_setShowActivityIndicatorView(true)
                cell.userImageView.sd_setIndicatorStyle(.gray)
                cell.userImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: ""))
                
            }
            else {
                cell.userImageView.image = UIImage.init(named: "UserPlaceholder")
            }
            
            if let messageCount = self.filteredOnlineUserListArray[indexPath.row].newMessageCount {
                if messageCount > 0 {
                    cell.unreadMessageLabel.isHidden = false
                    cell.unreadMessageLabel.text = String(messageCount)
                }
                else {
                    cell.unreadMessageLabel.isHidden = true
                }
            }
            else {
                cell.unreadMessageLabel.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView.tag == 1010 {
            self.receiverDeviceId = self.filteredRecentUserListArray[indexPath.row].deviceId
            self.receiverProfileName = self.filteredRecentUserListArray[indexPath.row].name
        }
        else {
            self.receiverDeviceId = self.filteredOnlineUserListArray[indexPath.row].deviceId
            self.receiverProfileName = self.filteredOnlineUserListArray[indexPath.row].name
        }
        if let _ = self.receiverDeviceId {
            self.performSegue(withIdentifier: "chatMessageCell", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(8.0, 0.0, 8.0, 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100, height: 138)
    }

}
