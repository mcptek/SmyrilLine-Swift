//
//  InboxViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/13/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SwiftyJSON
import SDWebImage
import ObjectMapper

class InboxViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UISearchBarDelegate {
    
    @IBOutlet weak var chatSearchBar: UISearchBar!
    var activityIndicatorView: UIActivityIndicatorView!
    var OnlineUserListArray = [User]()
    var filteredOnlineUserListArray = [User]()
    var RecentUserListArray = [User]()
    var filteredRecentUserListArray = [User]()
    var receiverDeviceId: String?
    var receiverProfileName: String?
    var receiverProfileStatus: Int?
    //var chatGroupArray: [chatSessionViewModel]?
    
    
    @IBOutlet weak var inboxTableview: UITableView!
    @IBOutlet weak var chatSegmentController: UISegmentedControl!
    @IBOutlet weak var addUserContainerView: UIView!
    @IBOutlet weak var addUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        //self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.view.backgroundColor = UIColor(red: 0.03, green: 0.54, blue: 0.84, alpha: 1.0)
        self.title = "Messaging"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        //let navigationBar = navigationController!.navigationBar
        //navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        
        self.addUserContainerView.layer.cornerRadius = self.addUserContainerView.frame.size.width / 2
        self.addUserContainerView.layer.masksToBounds = true
        
        self.addUserContainerView.layer.shadowColor = UIColor.gray.cgColor
        self.addUserContainerView.layer.shadowOpacity = 0.3
        self.addUserContainerView.layer.shadowOffset = CGSize.zero
        self.addUserContainerView.layer.shadowRadius = 6
        
        self.addUserContainerView.bringSubview(toFront: self.view)
        self.addUserContainerView.isHidden = true
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateChatUserList), name: NSNotification.Name(rawValue: "UpdateChatUserList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageCounter), name: NSNotification.Name(rawValue: "UpdateMessageCountList"), object: nil)
        if (UserDefaults.standard.value(forKey: "BookingNo") as? String) == nil {
            self.showAlertIfBookingNumberIsNotSet()
        }
        else if (UserDefaults.standard.value(forKey: "userName") as? String) == nil {
            self.showAlertIfUsernameIsNotSet()
        }
        else {
            if self.chatSegmentController.selectedSegmentIndex == 0 {
                self.RetrieveCurrentUserList()
            }
            else {
                self.retrieveChatGroupList()
//                if let numberOfGroups = chatData.shared.allGroups?.count{
//                    if numberOfGroups > 0 {
//                        self.inboxTableview.reloadData()
//                    }
//                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.chatSearchBar.resignFirstResponder()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reachabilityChanged"), object: nil)
        NotificationCenter.default.removeObserver(self)
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
    
    
    @IBAction func menuButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "chatStatusvisibilityPage", sender: nil)
    }
    
    func showAlertIfUsernameIsNotSet() {
        if (UserDefaults.standard.value(forKey: "userName") as? String) == nil {
            print("Username exists")
            let message = "You can review your profile anytime from Messaging > Menu > My Profile"
            let alertController = UIAlertController(
                title: "Verify your chat profile", // This gets overridden below.
                message: message,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel) { _ -> Void in
                self.performSegue(withIdentifier: "chatStatusvisibilityPage", sender: nil)
            }
            alertController.addAction(okAction)
            
            let fontAwesomeHeart = "Messaging > Menu > My Profile"
            let fontAwesomeFont = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
            
            let customTitle:NSString = "You can review your profile anytime from Messaging > Menu > My Profile" as NSString // Use NSString, which lets you call rangeOfString()
            let systemBoldAttributes:[String : AnyObject] = [
                // setting the attributed title wipes out the default bold font,
                // so we need to reconstruct it.
                NSFontAttributeName : UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)//UIFont.boldSystemFont(ofSize: 17)
            ]
            let attributedString = NSMutableAttributedString(string: customTitle as String, attributes:systemBoldAttributes)
            let fontAwesomeAttributes = [
                NSFontAttributeName: fontAwesomeFont,
                NSForegroundColorAttributeName : UIColor.black
            ]
            let matchRange = customTitle.range(of: fontAwesomeHeart)
            attributedString.addAttributes(fontAwesomeAttributes, range: matchRange)
            alertController.setValue(attributedString, forKey: "attributedMessage")
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertIfBookingNumberIsNotSet() {
        if (UserDefaults.standard.value(forKey: "BookingNo") as? String) == nil {
            let alertController = UIAlertController(title: "Booking information needed",
                                                    message: "Please log in to view booking first.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel) { _ -> Void in
                self.performSegue(withIdentifier: "BookingLoginView", sender: nil)
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
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
        let bookingNumber = UserDefaults.standard.value(forKey: "BookingNo") as! String
        let userSex = UserDefaults.standard.value(forKey: "passengerSex") as! String
        let userNationality = UserDefaults.standard.value(forKey: "passengerNationality") as! String
        
        let params: Parameters = [
            "bookingNo": Int(bookingNumber) ?? 123456,
            "Name": userName,
            "description": introInfo,
            "imageUrl": imageUrl,
            "country": userNationality,
            "deviceId": (UIDevice.current.identifierForVendor?.uuidString)!,
            "gender": userSex,
            "status": status,
            "visibility": visibilityStatus,
            "phoneType": "iOS",
            ]
        return params
    }
    
    func retrieveChatGroupList() {
        let url = UrlMCP.server_base_url + UrlMCP.showAllGroup + "?deviceId=" + (UIDevice.current.identifierForVendor?.uuidString)!
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers)
            .responseArray { (response: DataResponse<[chatSessionViewModel]>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    let forecastArray = response.result.value
                    if let UserList = forecastArray {
                        //chatData.shared.allGroups?.removeAll()
                        chatData.shared.allGroups = UserList
                        print(chatData.shared.allGroups?.count ?? "0")
                        self.inboxTableview.reloadData()
                    }
                    else {
                        self.showAlert(title: "Message", message: "No user list found")
                    }
                case .failure(let error):
                    self.showErrorAlert(error: error as NSError)
                }
        }
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
    
    func updateChatUserList(_ notification: Notification) {
        if let myDict = notification.userInfo as? [String: [User]] {
            if let userList = myDict["UserList"] {
                self.filterChatUserList(UserList: userList)
            }
        }
    }
    
    func updateMessageCounter(_ notification: Notification) {
        if let dic = notification.userInfo as? [String: Any] {
            if let senderChatUserServerModel = dic["senderChatUserServerModel"] as? [String: Any] {
                self.updateMessageCounterListforDeviceId(deviceId: (senderChatUserServerModel["deviceId"] as? String)!, lastCommunicationTime: (senderChatUserServerModel["lastCommunication"] as? Int64)!, lastSeenTime: (senderChatUserServerModel["lastSeen"] as? Int64)!)
            }
        }
    }
    
    func updateMessageCounterListforDeviceId(deviceId: String, lastCommunicationTime:Int64, lastSeenTime:Int64)  {
        if self.filteredRecentUserListArray.contains(where: { $0.deviceId == deviceId }) {
            if let index = self.filteredRecentUserListArray.index(where: { $0.deviceId == deviceId }) {
                self.filteredRecentUserListArray[index].lastCommunication = lastCommunicationTime
                self.filteredRecentUserListArray[index].lastSeen = lastSeenTime
                //print(self.filteredRecentUserListArray[index].newMessageCount ?? "Default  ")
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
    
    func filterChatUserList(UserList: [User] )  {
        
        self.OnlineUserListArray.removeAll()
        self.filteredOnlineUserListArray.removeAll()
        self.RecentUserListArray.removeAll()
        self.filteredRecentUserListArray.removeAll()
        
        for object in UserList {
            print(object.name?.base64Decoded() ?? "Name not found", object.visibility ?? "Visibility not found",object.status ?? "Status not found")
            if let deviviceId = object.deviceId {
                if deviviceId == (UIDevice.current.identifierForVendor?.uuidString)! {
                    /*
                    if let imageUrl = object.imageUrl {
                        UserDefaults.standard.set(imageUrl, forKey: "userProfileImageUrl")
                    }
                    if let userName = object.name {
                        UserDefaults.standard.set(userName, forKey: "userName")
                    }
                    if let intro = object.description {
                        UserDefaults.standard.set(intro, forKey: "introInfo")
                    }
 */
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
        chatData.shared.allUser = self.filteredRecentUserListArray + self.filteredOnlineUserListArray
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
            if let status = self.receiverProfileStatus {
                vc.profileStatus = status
            }
        }
//        else if segue.identifier == "groupSelection" {
//            let vc = segue.destination as! CreateGroupViewController
//            vc.groupCreation = true
//        }
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
    
    @IBAction func addUserAction(_ sender: Any) {
        chatData.shared.creatingChatGroups = true
        self.performSegue(withIdentifier: "groupSelection", sender: self)
        
    }
    
    @IBAction func segmentButtonAction(_ sender: Any) {
        if self.chatSegmentController.selectedSegmentIndex == 0 {
            self.addUserContainerView.isHidden = true
            self.inboxTableview.reloadData()
        }
        else {
            self.addUserContainerView.isHidden = false
//            self.inboxTableview.reloadData()
            //self.retrieveChatGroupList()
            if chatData.shared.allGroups == nil || chatData.shared.allGroups?.count == 0 {
                self.retrieveChatGroupList()
            }
            else {
                self.inboxTableview.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.chatSegmentController.selectedSegmentIndex == 0 {
            var totalSection = 0
            if self.filteredRecentUserListArray.count > 0 {
                totalSection += 1
            }
            if self.filteredOnlineUserListArray.count > 0 {
                totalSection += 1
            }
            return totalSection
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.chatSegmentController.selectedSegmentIndex == 0 {
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
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupChatTableViewCell
            cell.groupChatCollectionView.tag = 1012
            cell.groupChatCollectionView.reloadData()
            cell.collectionViewHeight.constant = cell.groupChatCollectionView.collectionViewLayout.collectionViewContentSize.height
            cell.groupChatCollectionView.layoutIfNeeded()
            cell.layoutIfNeeded()
            self.inboxTableview.layoutIfNeeded()
            cell.selectionStyle = .none
            return cell
        }
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
        else if collectionView.tag == 1011 {
            return self.filteredOnlineUserListArray.count
        }
        else {
            return chatData.shared.allGroups?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if self.chatSegmentController.selectedSegmentIndex == 0 {
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
                    cell.userImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
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
                    cell.userImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
                    
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
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatGrouprCell", for: indexPath) as! ChatGroupListCollectionViewCell
            cell.groupNameLabel.text = chatData.shared.allGroups![indexPath.row].groupName
            cell.topLeftImageView.isHidden = true
            cell.topRightImageView.isHidden = true
            cell.bottomLeftImageView.isHidden = true
            cell.bottomRightImageView.isHidden = true
            cell.bottomStackView.isHidden = true
            if (chatData.shared.allGroups![indexPath.row].memberDevices?.count)! >= 1 {
                if let imageUrlStr = chatData.shared.allGroups![indexPath.row].memberDevices![0].imageUrl
                {
                    cell.topLeftImageView.isHidden = false
                    cell.topLeftImageView.sd_setShowActivityIndicatorView(true)
                    cell.topLeftImageView.sd_setIndicatorStyle(.gray)
                    cell.topLeftImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
                }
                else {
                    cell.topLeftImageView.isHidden = false
                    cell.topLeftImageView.image = UIImage.init(named: "UserPlaceholder")
                }
            }
            
            if (chatData.shared.allGroups![indexPath.row].memberDevices?.count)! >= 2 {
                if let imageUrlStr = chatData.shared.allGroups![indexPath.row].memberDevices![1].imageUrl
                {
                    cell.topRightImageView.isHidden = false
                    cell.topRightImageView.sd_setShowActivityIndicatorView(true)
                    cell.topRightImageView.sd_setIndicatorStyle(.gray)
                    cell.topRightImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
                }
                else {
                    cell.topRightImageView.isHidden = false
                    cell.topRightImageView.image = UIImage.init(named: "UserPlaceholder")
                }
            }
            
            if (chatData.shared.allGroups![indexPath.row].memberDevices?.count)! >= 3 {
                if let imageUrlStr = chatData.shared.allGroups![indexPath.row].memberDevices![2].imageUrl
                {
                    cell.bottomStackView.isHidden = false
                    cell.bottomLeftImageView.isHidden = false
                    cell.bottomLeftImageView.sd_setShowActivityIndicatorView(true)
                    cell.bottomLeftImageView.sd_setIndicatorStyle(.gray)
                    cell.bottomLeftImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
                }
                else {
                    cell.bottomStackView.isHidden = false
                    cell.bottomLeftImageView.isHidden = false
                    cell.bottomLeftImageView.image = UIImage.init(named: "UserPlaceholder")
                }
            }
            
            if (chatData.shared.allGroups![indexPath.row].memberDevices?.count)! >= 4 {
                if let imageUrlStr = chatData.shared.allGroups![indexPath.row].memberDevices![3].imageUrl
                {
                    cell.bottomRightImageView.isHidden = false
                    cell.bottomRightImageView.sd_setShowActivityIndicatorView(true)
                    cell.bottomRightImageView.sd_setIndicatorStyle(.gray)
                    cell.bottomRightImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
                }
                else {
                    cell.bottomRightImageView.isHidden = false
                    cell.bottomRightImageView.image = UIImage.init(named: "UserPlaceholder")
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if self.chatSegmentController.selectedSegmentIndex == 0 {
            if collectionView.tag == 1010 {
                self.receiverDeviceId = self.filteredRecentUserListArray[indexPath.row].deviceId
                self.receiverProfileName = self.filteredRecentUserListArray[indexPath.row].name
                self.receiverProfileStatus = self.filteredRecentUserListArray[indexPath.row].status
            }
            else {
                self.receiverDeviceId = self.filteredOnlineUserListArray[indexPath.row].deviceId
                self.receiverProfileName = self.filteredOnlineUserListArray[indexPath.row].name
                self.receiverProfileStatus = self.filteredOnlineUserListArray[indexPath.row].status
            }
            if let _ = self.receiverDeviceId {
                self.performSegue(withIdentifier: "chatMessageCell", sender: nil)
            }
        }
        else {
            chatData.shared.groupChatObject = chatData.shared.allGroups?[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "groupChatContainer") as! GroupChatContainerViewController
            //vc.groupChatObject = chatData.shared.allGroups?[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
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
        if collectionView.tag == 1012 {
            return CGSize(width: 115, height: 138)
        }
        else {
            return CGSize(width: 100, height: 138)
        }
    }

}
