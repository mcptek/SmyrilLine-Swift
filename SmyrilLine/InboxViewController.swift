//
//  InboxViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/13/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import Starscream
import ObjectMapper
//import TOSearchBar
import SDWebImage

class InboxViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WebSocketDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var chatSearchBar: UISearchBar!
    
    var messageArray:[Message]?
    var messageObject: Message?
    var OnlineUserListArray = [User]()
    var filteredOnlineUserListArray = [User]()
    var RecentUserListArray = [User]()
    var filteredRecentUserListArray = [User]()
    
    @IBOutlet weak var inboxSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var inboxTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        //self.title = "Inbox"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        //let navigationBar = navigationController!.navigationBar
        //navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        
        self.inboxTableview.estimatedRowHeight = 150
        self.inboxTableview.rowHeight = UITableViewAutomaticDimension
        self.configureSearchBar()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.configureSearchBar()
        //self.navigationController?.navigationBar.backItem?.title = ""
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
        self.newMessageReceived()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(newMessageReceived), name: Notification.Name("InboxNotification"), object: nil)
        self.navigationController?.navigationBar.isHidden = false
       // let navigationBar = navigationController!.navigationBar
       // navigationBar.attachToScrollView(self.inboxTableview)
        
        //let textFieldInsideSearchBar = self.chatSearchBar.value(forKey: "searchField") as? UITextField
        //textFieldInsideSearchBar?.textColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: Notification.Name("InboxNotification"), object: nil)
       // let navigationBar = navigationController!.navigationBar
       // navigationBar.reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
 
        if let searchTextField = self.chatSearchBar.value(forKey: "_searchField") as? UITextField, let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton {
            // Create a template copy of the original button image
            let templateImage =  clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            // Set the template image copy as the button image
            clearButton.setImage(templateImage, for: .normal)
            // Finally, set the image color
            clearButton.tintColor = UIColor.white
        }

        self.chatSearchBar.setImage(UIImage(), for: .clear, state: .normal)
        self.chatSearchBar.delegate = self

    }
    
    func RetrieveCurrentUserList() {
        let userListObject = CurrentUserList.init(name: "Rafay", bookingNumber: 123456, profileDescription: "Websoket messaging", imageUrl: "", country: "Bangladesh", deviceId: (UIDevice.current.identifierForVendor?.uuidString)!, gender: "Male", status: 1, visibility: 2)
        let messageType = MessageSignature.init(type: 5, list: userListObject)
        let json = JSONSerializer.toJson(messageType)
        WebSocketSharedManager.sharedInstance.socket?.write(string: json)
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
        self.RetrieveCurrentUserList()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        self.OnlineUserListArray.removeAll()
        self.filteredOnlineUserListArray.removeAll()
        self.RecentUserListArray.removeAll()
        self.filteredRecentUserListArray.removeAll()
        if let arr: Array<Messaging> = Mapper<Messaging>().mapArray(JSONString: text) {
            if let userType = arr[0].MessageType {
                if userType == 5 {
                    if let UserList = arr[0].userList {
                        for object in UserList {
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
                        self.inboxTableview.reloadData()
                    }
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func newMessageReceived()  {
        if #available(iOS 10.0, *) {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            self.messageArray = appDelegate?.retrieveAllInboxMessages()
            self.inboxTableview.reloadData()
        } else {
            // Fallback on earlier versions
        }

    }

    @IBAction func segmentButtonAction(_ sender: Any) {

        self.inboxTableview.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "inboxDetails"
        {
            let vc = segue.destination as! InboxDetailsViewController
            let indexPath = self.inboxTableview.indexPathForSelectedRow
            vc.messageObject = self.messageArray?[(indexPath?.section)!]
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filteredRecentUserListArray.removeAll()
        self.filteredOnlineUserListArray.removeAll()
        
        self.filteredRecentUserListArray = self.RecentUserListArray.filter({ (object: User) -> Bool in
            return (object.name?.lowercased().range(of: searchText.lowercased()) != nil)
        })
        
        self.filteredOnlineUserListArray = self.OnlineUserListArray.filter({ (object: User) -> Bool in
            return (object.name?.lowercased().range(of: searchText.lowercased()) != nil)
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
        
        switch self.inboxSegmentControl.selectedSegmentIndex {
        case 0:
            var totalSection = 0
            if self.RecentUserListArray.count > 0 {
                totalSection += 1
            }
            if self.OnlineUserListArray.count > 0 {
                totalSection += 1
            }
            return totalSection
        default:
            return self.messageArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.inboxSegmentControl.selectedSegmentIndex {
        case 0:
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
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath) as! InboxTableViewCell
            messageObject = self.messageArray?[indexPath.section]
            cell.messageTitleLabel.text = messageObject?.messageTitle
            cell.messageDetailsLabel.text = messageObject?.messageDetails
            if messageObject?.messageStatus == NSNumber(value: false)
            {
                
                cell.messageReadUnreadStatusLabel.textColor = UIColor(red: 52.0/255, green: 152.0/255, blue: 219.0/255, alpha: 1.0)
            }
            else
            {
                cell.messageReadUnreadStatusLabel.textColor = UIColor.clear
            }
            
            let date = NSDate(timeIntervalSince1970: TimeInterval((messageObject?.messageTime)!))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            
            cell.messageDateLabel.text = dateFormatter.string(from: date as Date)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.inboxSegmentControl.selectedSegmentIndex == 2 {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if #available(iOS 10.0, *) {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                messageObject = self.messageArray?[indexPath.section]
                appDelegate?.deleteMessageforMessageId(messageId: (messageObject?.messageId)!)
                self.messageArray?.removeAll()
                self.messageArray = appDelegate?.retrieveAllInboxMessages()
                self.inboxTableview.reloadData()
            } else {
                // Fallback on earlier versions
            }
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
        vw.backgroundColor = UIColor.white
        return vw
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let vw = UIView()
        vw.backgroundColor = UIColor.white
        
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
            if self.filteredRecentUserListArray[indexPath.row].status == 1 {
                cell.onlineTrackerImageView.isHidden = false
            }
            else {
                cell.onlineTrackerImageView.isHidden = true
            }
            if let name = self.filteredRecentUserListArray[indexPath.row].name {
                cell.userNameLabel.text = name
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
        }
        else {
            cell.userNameLabel.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
            cell.userImageView.backgroundColor = UIColor.white
            cell.userNameLabel.textColor = UIColor(red: 0.0/255, green: 135.0/255, blue: 215.0/255, alpha: 1.0)
            cell.userImageView.layer.cornerRadius = 0
            cell.userImageView.clipsToBounds = true
            cell.onlineTrackerImageView.isHidden = false
            if let name = self.filteredOnlineUserListArray[indexPath.row].name {
                cell.userNameLabel.text = name
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
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
//        if let objectId = self.shopObject?.itemArray?[indexPath.row].objectId
//        {
//            self.CallTaxfreeShopDetailsAPIwithObjectId(objectId: objectId)
//        }
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
