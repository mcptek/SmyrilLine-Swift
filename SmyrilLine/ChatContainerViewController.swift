//
//  ChatContainerViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/21/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

//import UIKit
//import KMPlaceholderTextView
//import AlamofireObjectMapper
//import Alamofire
//import SwiftyJSON
//import SDWebImage
//import ObjectMapper
import UIKit
import Starscream
import AlamofireObjectMapper
import Alamofire
import SwiftyJSON
import SDWebImage
import ObjectMapper
import KMPlaceholderTextView
import IQKeyboardManagerSwift
import ISEmojiView

class ChatContainerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, WebSocketDelegate,ISEmojiViewDelegate {
    @IBOutlet weak var chatTableView: UITableView!
    var senderDeviceId: String?
    var receiverDeviceId: String?
    var activityIndicatorView: UIActivityIndicatorView!
    var profileName: String?
    var pageCount = 0
    var heightOfKeyboard = 0
    
    
    @IBOutlet weak var keyboardBackgroundBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var keyboardBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: KMPlaceholderTextView!
    @IBOutlet weak var emojiButton: UIButton!
    
    var messagesArray:[Chat] = []
    var myMessageArray = [UserChatMessage]()
    
    override func viewDidLoad() { 
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.chatTableView.estimatedRowHeight = 44
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        IQKeyboardManager.sharedManager().enable = false
        self.title = self.profileName
        self.emojiButton.setImage(UIImage.init(named: "smile"), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.messagesArray.removeAll()
        WebSocketSharedManager.sharedInstance.socket?.delegate = self
        if WebSocketSharedManager.sharedInstance.socket?.isConnected == false {
            WebSocketSharedManager.sharedInstance.socket?.connect()
        }
        else {
            self.LoadChatHisroryWithMessageCount(messageCount: self.pageCount)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight : Int = Int(keyboardSize.height)
            print("keyboardHeight",keyboardHeight)
            if self.heightOfKeyboard == 0 {
                self.heightOfKeyboard = keyboardHeight
            }
            if keyboardHeight < self.heightOfKeyboard {
                self.heightOfKeyboard = keyboardHeight
            }
            
            self.keyboardBottomHeight.constant = CGFloat(self.heightOfKeyboard)
            self.keyboardBackgroundBottomHeight.constant = CGFloat(self.heightOfKeyboard)
            self.view.setNeedsLayout()
            if self.messagesArray.count > 0 {
                let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        self.keyboardBottomHeight.constant = 0
        self.keyboardBackgroundBottomHeight.constant = 0
        self.view.setNeedsLayout()
        if self.messagesArray.count > 0 {
            let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
        
    }
    @IBAction func emojiKeyboardButtonAction(_ sender: Any) {
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
    
    func LoadChatHisroryWithMessageCount(messageCount: Int) {
        let params: Parameters = [
            "senderId": self.receiverDeviceId!,
            "receiverId": self.senderDeviceId!,
            "pageNo": messageCount
            ]
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let urlStr = UrlMCP.server_base_url + UrlMCP.LoadMoreFromSender
        
        Alamofire.request(urlStr, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers)
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
                                
                                if let local = member.fromLocalClient {
                                    fromLocal = local
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
                            self.chatTableView.reloadData()
                            if self.messagesArray.count > 0 && self.pageCount == 0 {
                                let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                                self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                            }
                            
                            if self.messagesArray.count > 0 {
                                self.pageCount += 1
                            }
                            
                        }
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
        self.LoadChatHisroryWithMessageCount(messageCount: self.pageCount)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        if let arr: Array<Messaging> = Mapper<Messaging>().mapArray(JSONString: text) {
            print(arr[0].Message ?? "Default value")
            if let userType = arr[0].MessageType {
                switch(userType) {
                case 3:
                    // Receive message acknowledgement status
                    let status = arr[0].Message?["MessageSendingStatus"] as! Int
                    self.messagesArray.filter{ $0.messageId == arr[0].Message?["MessageId"] as! String }.first?.type = Chat.MessageSendingStatus(rawValue: Chat.MessageSendingStatus.RawValue(status))!
                    if let index = self.messagesArray.index(where: { $0.messageId == arr[0].Message?["MessageId"] as! String }) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.chatTableView.reloadRows(at: [indexPath], with: .none)
                    }

                    //self.chatTableView.reloadData()
//                    if self.messagesArray.count > 0 {
//                        let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
//                        self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
//                    }
                case 8:
                    // Receive Message
                    var imagestr = ""
                    if let dic = arr[0].Message?["senderChatUserServerModel"] as? [String: Any] {
                        if let img = dic["imageUrl"] as? String  {
                            imagestr = img
                        }
                    }
                    self.callAcknowledgeMessageWebserviceForMessageId(messageId: arr[0].Message?["messageId"] as! String)
                    
                    var timeStr = ""
                    if let tm = arr[0].Message?["sendTime"] as? Double {
                        let date = Date(timeIntervalSince1970: (tm / 1000.0))
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "hh:mm a" //Specify your format that you want
                        timeStr = dateFormatter.string(from: date)
                    }
                    self.messagesArray.append(Chat(message: arr[0].Message?["messageBase64"] as! String, messageid: arr[0].Message?["messageId"] as! String, time: timeStr, imageString: imagestr, fromLocalClient: false, messageStatus: Chat.MessageSendingStatus.seen))
                    self.chatTableView.reloadData()
                    if self.messagesArray.count > 0 {
                        let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                        self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
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
    
    func callAcknowledgeMessageWebserviceForMessageId(messageId: String) {
        let messageSendingStatus = 3
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messagesArray[indexPath.row].fromLocalClient {
            let cell = tableView.dequeueReusableCell(withIdentifier: "outGoingMessagingCell", for: indexPath) as! OutgoingMessageTableViewCell
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMessagingCell", for: indexPath) as! IncomingMessageTableViewCell
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
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//    }
    
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
            self.LoadChatHisroryWithMessageCount(messageCount: self.pageCount)
        }
    }
    
    @IBAction func messageSendButtonAction(_ sender: Any) {
        if self.messageTextView.text.count > 0 {
            let messageId = NSUUID().uuidString.lowercased()
            let params: Parameters = [
                "senderDeviceId": self.senderDeviceId!,
                "receiverDeviceId": self.receiverDeviceId!,
                "messageBase64": self.messageTextView.text.base64Encoded() ?? "",
                "messageId": messageId,
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
            self.chatTableView.reloadData()
            let headers = ["Content-Type": "application/x-www-form-urlencoded"]
            let url = UrlMCP.server_base_url + UrlMCP.SendMessageToServer
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                print(response.response?.statusCode ?? "no status code")
                if response.response?.statusCode == 200 {
                    self.messagesArray.filter{ $0.messageId == messageId }.first?.type = Chat.MessageSendingStatus.sent
                    if let index = self.messagesArray.index(where: { $0.messageId == messageId }) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.chatTableView.reloadRows(at: [indexPath], with: .none)
                    }
                    if self.messagesArray.count > 0 {
                        let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                        self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                    }
                    self.messageTextView.text = nil
                }
                else {
                    self.showAlert(title: "Message", message: "Message sending failed. Please try again later")
                    self.messagesArray.filter{ $0.messageId == messageId }.first?.type = Chat.MessageSendingStatus.failed
                    if let index = self.messagesArray.index(where: { $0.messageId == messageId }) {
                        let indexPath = IndexPath(item: index, section: 0)
                        self.chatTableView.reloadRows(at: [indexPath], with: .none)
                    }
                    if self.messagesArray.count > 0 {
                        let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                        self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                    }
                    self.messageTextView.text = nil
                }
                
            }
        }
    }
    
}
