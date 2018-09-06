 //
//  GroupChatContainerViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 28/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SwiftyJSON
import SDWebImage
import ObjectMapper
import KMPlaceholderTextView
import ISEmojiView
import Toast_Swift
 
class GroupChatContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ISEmojiViewDelegate, UITableViewDelegate, UITableViewDataSource {

    //var groupChatObject: chatSessionViewModel?
    @IBOutlet weak var groupChatMembersCollectionview: UICollectionView!
    @IBOutlet weak var groupChatTableview: UITableView!
    @IBOutlet weak var messageTextView: KMPlaceholderTextView!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var keyboardBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var backgroundViewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var messageSendButton: UIButton!
    
    var heightOfKeyboard = 0
    var pageCount = 0
    var activityIndicatorView: UIActivityIndicatorView!
    var messagesArray:[Chat] = []
    var myMessageArray = [UserChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        self.title = chatData.shared.groupChatObject?.groupName
        self.emojiButton.setImage(UIImage.init(named: "smile"), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.title = chatData.shared.groupChatObject?.groupName
        self.groupChatMembersCollectionview.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InsertGroupMessage), name: NSNotification.Name(rawValue: "InsertNewMessageForGroup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroup), name: NSNotification.Name(rawValue: "groupUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteGroup), name: NSNotification.Name(rawValue: "groupDeleted"), object: nil)
        self.messagesArray.removeAll()
        self.LoadGroupChatHisroryWithMessageCount(messageCount: self.pageCount)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "groupMenu" {
//            let vc = segue.destination as! GroupChatMenuViewController
//            vc.groupChatObject = self.groupChatObject
//        }
    }
    
    func InsertGroupMessage(_ notification: Notification) {
        if let dic = notification.userInfo as? [String: Any] {
            if let myDic = dic["newMessage"] as? [String: Any] {
                if myDic["sessionId"] as? String == chatData.shared.groupChatObject?.sessionId {
                    var imagestr = ""
                    if let userServerModel = myDic["senderChatUserServerModel"] as? [String: Any] {
                        if let img = userServerModel["imageUrl"] as? String  {
                            imagestr = img
                        }
                    }
                    
                    var timeStr = ""
                    if let tm = myDic["sendTime"] as? Double {
                        let date = Date(timeIntervalSince1970: (tm / 1000.0))
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "hh:mm a" //Specify your format that you want
                        timeStr = dateFormatter.string(from: date)
                    }
                    self.messagesArray.append(Chat(message: myDic["messageBase64"] as! String, messageid: myDic["messageId"] as! String, time: timeStr, imageString: imagestr, fromLocalClient: false, messageStatus: Chat.MessageSendingStatus.seen))
                    self.groupChatTableview.reloadData()
                    if self.messagesArray.count > 0 {
                        let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                        self.groupChatTableview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                    }
                }
            }
        }
    }
    
    func deleteGroup(_ notification: Notification) {
        if let dic = notification.userInfo as? [String: Any] {
            if let allGroupListArray = dic["newMessage"] as? [chatSessionViewModel] {
                if allGroupListArray.index(where: { $0.sessionId == chatData.shared.groupChatObject?.sessionId }) == nil {
                    // the current group is deleted
                    let alertController = UIAlertController(title: "Message", message: "Group " + (chatData.shared.groupChatObject?.groupName)! + " is deleted by owner", preferredStyle: .alert)
                    // Create the actions
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.navigationController?.popViewController(animated: true)
                    }
                    // Add the actions
                    alertController.addAction(okAction)
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func updateGroup(_ notification: Notification) {
        if let dic = notification.userInfo as? [String: Any] {
            if let myDic = dic["newMessage"] as? [String: Any] {
                if myDic["sessionId"] as? String == chatData.shared.groupChatObject?.sessionId {
                    if let objectData = Mapper<chatSessionViewModel>().map(JSON: myDic) {
                        if objectData.groupName != chatData.shared.groupChatObject?.groupName {
                            // Group name updated
                            self.view.makeToast("Group name updated.", duration: 2.0, position: .bottom)
                            self.title = objectData.groupName
                        }
                        else if (objectData.memberDevices?.count)! > (chatData.shared.groupChatObject?.memberDevices?.count)! {
                            // Member updated
                            self.view.makeToast("New member added.", duration: 2.0, position: .bottom)
                        }
                        else if (objectData.memberDevices?.count)! < (chatData.shared.groupChatObject?.memberDevices?.count)! {
                            // Member left
                            self.view.makeToast("Member left.", duration: 2.0, position: .bottom)
                        }
                        chatData.shared.groupChatObject = objectData
                        self.groupChatMembersCollectionview.reloadData()
                    }
                    
                    //print(objectData?.groupName ?? "No group name found")
                }
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight : Int = Int(keyboardSize.height)
            if self.heightOfKeyboard == 0 {
                self.heightOfKeyboard = keyboardHeight
            }
            if keyboardHeight < self.heightOfKeyboard {
                self.heightOfKeyboard = keyboardHeight
            }
            
            
            if self.keyboardBottomHeight.constant != CGFloat(self.heightOfKeyboard) {
                self.keyboardBottomHeight.constant = CGFloat(self.heightOfKeyboard)
                self.backgroundViewBottomHeight.constant = CGFloat(self.heightOfKeyboard)
                self.view.setNeedsLayout()
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if self.keyboardBottomHeight.constant != 0.0 {
            self.keyboardBottomHeight.constant = 0
            self.backgroundViewBottomHeight.constant = 0
            self.view.setNeedsLayout()
        }
        
    }
    
    @IBAction func emojiButtonAction(_ sender: Any) {
        if self.emojiButton.image(for: .normal) == UIImage.init(named: "smile") {
            let emojiView = ISEmojiView()
            emojiView.delegate = self
            //self.messageTextView.resignFirstResponder()
            self.messageTextView.inputView = emojiView
            self.messageTextView.inputView?.autoresizingMask = .flexibleHeight
            self.messageTextView.reloadInputViews()
            //self.messageTextView.becomeFirstResponder()
            self.emojiButton.setImage(UIImage.init(named: "keyboard"), for: .normal)
        }
        else {
            //self.messageTextView.resignFirstResponder()
            self.messageTextView.inputView = nil
            self.messageTextView.inputView?.autoresizingMask = .flexibleHeight
            self.messageTextView.reloadInputViews()
            //self.messageTextView.becomeFirstResponder()
            self.emojiButton.setImage(UIImage.init(named: "smile"), for: .normal)
        }
    }
    
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        self.messageTextView.insertText(emoji)
    }
    
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        self.messageTextView.deleteBackward()
    }
    
    func LoadGroupChatHisroryWithMessageCount(messageCount: Int) {
        let cnt = String(messageCount)
        let LoadGroupChatHistoryFromSender = String(format: "/chat/api/v2/LoadPagedSessionMessages?SessionId=%@&PageNo=%@&PageSize=10", chatData.shared.groupChatObject?.sessionId ?? "", cnt)
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let urlStr = UrlMCP.server_base_url + LoadGroupChatHistoryFromSender
        
        Alamofire.request(urlStr, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers)
            .responseArray { (response: DataResponse<[UserChatMessage]>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        if let array = response.result.value {
                            self.myMessageArray = array
                            if self.pageCount > 0 {
                                self.myMessageArray = Array(self.myMessageArray.reversed())
                            }
                            for member in self.myMessageArray {
                                var message = ""
                                var imageUrlStr = ""
                                var time = 0.0
                                var timeStr = ""
                                var messageStatus = 100
                                var fromLocal = true
                                
                                if let msg = member.message {
                                    message = msg
                                }
                                
                                if let img = member.messageUrlString {
                                    imageUrlStr = img
                                }
                                
                                if let tm = member.sendTime {
                                    time = tm
                                    let date = Date(timeIntervalSince1970: (time / 1000.0))
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.timeZone = TimeZone.current //Set timezone that you want
                                    dateFormatter.locale = NSLocale.current
                                    dateFormatter.dateFormat = "hh:mm a" //Specify your format that you want
                                    timeStr = dateFormatter.string(from: date)
                                }
                                
                                if let local = member.senderId {
                                    if local == UIDevice.current.identifierForVendor?.uuidString {
                                        fromLocal = true
                                    }
                                    else {
                                        fromLocal = false
                                    }
                                }
                                
                                if let status = member.messageSendingStatus {
                                    messageStatus = status
                                }
                                
                                if self.pageCount == 0 {
                                    self.messagesArray.append(Chat(message: message, messageid: "", time: timeStr, imageString: imageUrlStr, fromLocalClient: fromLocal, messageStatus: Chat.MessageSendingStatus(rawValue: messageStatus)!))
                                }
                                else {
                                    self.messagesArray.insert(Chat(message: message, messageid: "", time: timeStr, imageString: imageUrlStr, fromLocalClient: fromLocal, messageStatus: Chat.MessageSendingStatus(rawValue: messageStatus)!), at: 0)
                                }
                            }
                            if array.count > 0 {
                                self.groupChatTableview.reloadData()
                                if self.messagesArray.count > 0 && self.pageCount == 0 {
                                    let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                                    self.groupChatTableview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                                }
                                
                                //self.pageCount = self.messagesArray.count / 10
                                if self.messagesArray.count > 0 {
                                    self.pageCount += 1
                                }
                            }
                        }
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    @IBAction func messageSendButtonAction(_ sender: Any) {
        if self.messageTextView.text.count > 0 {
            self.messageSendButton.isEnabled = false
            let messageId = NSUUID().uuidString.lowercased()
            let params: Parameters = [
                "messageId": messageId,
                "senderDeviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
                "receiverDeviceId": "",
                "receiverChatSessionId": chatData.shared.groupChatObject?.sessionId ?? "",
                "messageBase64": self.messageTextView.text.base64Encoded() ?? "",
                ]
            var timeStr = ""
            
            let timestamp = NSDate().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "hh:mm a" //Specify your format that you want
            timeStr = dateFormatter.string(from: date)
            self.messagesArray.append(Chat(message: self.messageTextView.text.base64Encoded() ?? "", messageid: messageId, time:timeStr, imageString: "", fromLocalClient: true, messageStatus: Chat.MessageSendingStatus.sending))
            self.groupChatTableview.reloadData()
            let headers = ["Content-Type": "application/x-www-form-urlencoded"]
            let url = UrlMCP.server_base_url + UrlMCP.SendGroupMessageToServer
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                print(response.response?.statusCode ?? "no status code")
                if response.response?.statusCode == 200 {
                    self.messagesArray.filter{ $0.messageId == messageId }.first?.type = Chat.MessageSendingStatus.sent
                    if let index = self.messagesArray.index(where: { $0.messageId == messageId }) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.groupChatTableview.reloadRows(at: [indexPath], with: .none)
                    }
                    if self.messagesArray.count > 0 {
                        let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                        self.groupChatTableview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                    }
                    self.messageTextView.text = nil
                    self.messageSendButton.isEnabled = true
                }
                else {
                    self.showAlert(title: "Message", message: "Message sending failed. Please try again later")
                    self.messagesArray.filter{ $0.messageId == messageId }.first?.type = Chat.MessageSendingStatus.failed
                    if let index = self.messagesArray.index(where: { $0.messageId == messageId }) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.groupChatTableview.reloadRows(at: [indexPath], with: .none)
                    }
                    if self.messagesArray.count > 0 {
                        let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                        self.groupChatTableview.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                    }
                    self.messageTextView.text = nil
                    self.messageSendButton.isEnabled = true
                }
                
            }
        }
    }
    
    @IBAction func menuBarButtonAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "groupMenu", sender: self)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return chatData.shared.groupChatObject?.memberDevices?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupContainerUserCell", for: indexPath) as! UserListCollectionViewCell
        cell.unreadMessageLabel.isHidden = true
        cell.userNameLabel.backgroundColor = UIColor.clear
        cell.userNameLabel.textColor = UIColor.white
        cell.userImageView.backgroundColor = UIColor.white
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
        cell.userImageView.clipsToBounds = true
        cell.onlineTrackerImageView.isHidden = true
        if let status = chatData.shared.groupChatObject?.memberDevices![indexPath.row].status {
            if status == 1 {
                cell.onlineTrackerImageView.isHidden = false
            }
        }
        if let name = chatData.shared.groupChatObject?.memberDevices![indexPath.row].name {
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
        
        if let imageUrlStr = chatData.shared.groupChatObject?.memberDevices![indexPath.row].imageUrl
        {
            cell.userImageView.sd_setShowActivityIndicatorView(true)
            cell.userImageView.sd_setIndicatorStyle(.gray)
            cell.userImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
        }
        else {
            cell.userImageView.image = UIImage.init(named: "UserPlaceholder")
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
//        let CellWidth = 100.0
//        let CellCount = Double(self.groupChatObject?.memberDevices?.count ?? 0)
//        let CellSpacing = 8.0
//
//        let totalCellWidth = CellWidth * CellCount
//        let totalSpacingWidth = CellSpacing * (CellCount - 1)
//
//        let leftInset = (collectionView.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messagesArray[indexPath.row].fromLocalClient {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupChatOutGoingMessagingCell", for: indexPath) as! OutgoingMessageTableViewCell
            cell.messageLabel.text = self.messagesArray[indexPath.row].message.base64Decoded()
            cell.timeLabel.text = self.messagesArray[indexPath.row].sendTime
            switch(self.messagesArray[indexPath.row].type) {
            case .sending:
                cell.messageStatusIcon.image = UIImage.init(named: "sendingIcon")
            case .sent:
                cell.messageStatusIcon.image = UIImage.init(named: "sentIcon")
            case .delevered:
                cell.messageStatusIcon.image = UIImage.init(named: "deleveredIcon")
            case .seen:
                cell.messageStatusIcon.image = UIImage.init(named: "seenIcon")
            case .failed:
                cell.messageStatusIcon.image = UIImage.init(named: "failedIcon")
            default:
                cell.messageStatusIcon.image = nil
            }
            cell.setNeedsLayout()
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupChaIncomingMessagingCell", for: indexPath) as! IncomingMessageTableViewCell
            cell.messagelabel.text = self.messagesArray[indexPath.row].message.base64Decoded()
            cell.timeLabel.text = self.messagesArray[indexPath.row].sendTime
            if self.messagesArray[indexPath.row].userImageUrlString.count > 0
            {
                let replaceStr = self.messagesArray[indexPath.row].userImageUrlString.replacingOccurrences(of: " ", with: "%20")
                cell.userImageView.sd_setShowActivityIndicatorView(true)
                cell.userImageView.sd_setIndicatorStyle(.gray)
                cell.userImageView.sd_setImage(with: URL(string: replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
            }
            else {
                cell.userImageView.image = UIImage.init(named: "UserPlaceholder")
            }
            cell.setNeedsLayout()
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0 {
            self.LoadGroupChatHisroryWithMessageCount(messageCount: self.pageCount)
        }
    }

}
