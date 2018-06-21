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

class ChatContainerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, WebSocketDelegate {
    @IBOutlet weak var chatTableView: UITableView!
    var senderDeviceId: String?
    var receiverDeviceId: String?
    var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var keyboardBackgroundBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var keyboardBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: KMPlaceholderTextView!
    
    var messagesArray:[Chat] = []
    var myMessageArray = [UserChatMessage]()
    
    override func viewDidLoad() { 
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.chatTableView.estimatedRowHeight = 44
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        IQKeyboardManager.sharedManager().enable = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.messagesArray.removeAll()
        WebSocketSharedManager.sharedInstance.socket?.delegate = self
        if WebSocketSharedManager.sharedInstance.socket?.isConnected == false {
            WebSocketSharedManager.sharedInstance.socket?.connect()
        }
        else {
            self.LoadChatHisroryWithMessageCount(messageCount: 0)
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
            self.keyboardBottomHeight.constant = CGFloat(keyboardHeight)
            self.keyboardBackgroundBottomHeight.constant = CGFloat(keyboardHeight)
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
                                
                                
                                self.messagesArray.append(Chat(message: message, messageid: "", time: timeStr, imageString: imageUrlStr, fromLocalClient: fromLocal, messageStatus: Chat.MessageSendingStatus(rawValue: messageStatus)!))
                            }
                            self.chatTableView.reloadData()
                            if self.messagesArray.count > 0 {
                                let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                                self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
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
        self.LoadChatHisroryWithMessageCount(messageCount: 0)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        if let arr: Array<Messaging> = Mapper<Messaging>().mapArray(JSONString: text) {
            //print(arr[0].Message)
            if let userType = arr[0].MessageType {
                switch(userType) {
                case 8:
                    print(arr[0].Message ?? "default value")
                    var imagestr = ""
                    if let dic = arr[0].Message?["senderChatUserServerModel"] as? [String: Any] {
                        if let img = dic["imageUrl"] as? String  {
                            imagestr = img
                        }
                    }
                    print(imagestr)
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
        
        
        
        //print(text)
//        let jsonData = text.data(using: .utf8)
//        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves) as? [String : Any]
//        if let dic = dictionary {
//            print(dic ?? "default")
//            if dic!["MessageType"] as? Int == 8 {
//                if let ParamDic = dic!["Param"] as? [String : Any] {
//                    var imageUrlStr = ""
//                    if let ImageDic = ParamDic["senderChatUserServerModel"] as? [String : Any] {
//                        if let image = ImageDic["imageUrl"] {
//                            imageUrlStr = image as! String
//                        }
//                    }
//                    self.callAcknowledgeMessageWebserviceForMessageId(messageId: ParamDic["messageId"] as! String)
//                    self.messagesArray.append(Chat(message: ParamDic["messageBase64"] as! String, time: ParamDic["sendTime"] as! Double, imageString: imageUrlStr, fromLocalClient: false ))
//                    self.chatTableView.reloadData()
//                }
//            }
//        }
       // print(dictionary ?? "Default value")
//        if dictionary[]
//
//        }
        
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
        print(self.messagesArray[indexPath.row].message.base64Decoded() ?? "default",self.messagesArray[indexPath.row].type, self.messagesArray[indexPath.row].fromLocalClient)
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
                cell.userImageView.image = nil
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
    
    @IBAction func messageSendButtonAction(_ sender: Any) {
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
        self.messagesArray.append(Chat(message: self.messageTextView.text.base64Encoded() ?? "", messageid: messageId, time:timeStr, imageString: "", fromLocalClient: true, messageStatus: Chat.MessageSendingStatus.none))
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = UrlMCP.server_base_url + UrlMCP.SendMessageToServer
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            print(response.response?.statusCode ?? "no status code")
            if response.response?.statusCode == 200 {
                self.messagesArray.filter{ $0.messageId == messageId }.first?.type = Chat.MessageSendingStatus.sent
                self.chatTableView.reloadData()
                if self.messagesArray.count > 0 {
                    let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                    self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                }
                self.messageTextView.text = nil
            }
            else {
                self.showAlert(title: "Message", message: "Message sending failed. Please try again later")
                self.messagesArray.filter{ $0.messageId == messageId }.first?.type = Chat.MessageSendingStatus.failed
                self.chatTableView.reloadData()
                if self.messagesArray.count > 0 {
                    let indexPath = NSIndexPath(row: self.messagesArray.count - 1, section: 0)
                    self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                }
                self.messageTextView.text = nil
            }
            
        }
    }
    
}
