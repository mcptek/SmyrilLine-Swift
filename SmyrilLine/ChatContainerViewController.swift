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

class ChatContainerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, WebSocketDelegate {
    @IBOutlet weak var chatTableView: UITableView!
    var senderDeviceId: String?
    var receiverDeviceId: String?
    var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var messageTextView: KMPlaceholderTextView!
    
    
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        WebSocketSharedManager.sharedInstance.socket?.delegate = self
        if WebSocketSharedManager.sharedInstance.socket?.isConnected == false {
            WebSocketSharedManager.sharedInstance.socket?.connect()
        }
        else {
            self.LoadChatHisrory()
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
    
    func LoadChatHisrory() {
        let params: Parameters = [
            "senderId": self.senderDeviceId!,
            "receiverId": self.receiverDeviceId!,
            "pageNo": self.myMessageArray.count
            ]
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let urlStr = UrlMCP.server_base_url + UrlMCP.LoadAllFromSender
        
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
                            if self.myMessageArray.count > 0 {
                                print(self.myMessageArray[0].message ?? "default")
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
        self.LoadChatHisrory()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        let jsonData = text.data(using: .utf8)
        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
        print(dictionary!)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.myMessageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "outGoingMessagingCell", for: indexPath) as! OutgoingMessageTableViewCell
        cell.messageLabel.text = self.myMessageArray[indexPath.row].message
        cell.setNeedsLayout()
        return cell
        
//        self.messageObject = self.messageArray[indexPath.row]
//        if self.messageObject?.messageType == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "incomingMessageCell", for: indexPath) as! IncomingMessageTableViewCell
//            cell.bubbleImageView.image = UIImage(named: "chat_bubble_received")?
//                .resizableImage(withCapInsets:
//                    UIEdgeInsetsMake(17, 21, 17, 21),
//                                resizingMode: .stretch)
//                .withRenderingMode(.alwaysTemplate)
//            cell.selectionStyle = .none
//            return cell
//        }
//        else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "outGoingMessagingCell", for: indexPath) as! OutgoingMessageTableViewCell
//            cell.bubbleImageView.image = UIImage(named: "chat_bubble_sent")?
//                .resizableImage(withCapInsets:
//                    UIEdgeInsetsMake(17, 21, 17, 21),
//                                resizingMode: .stretch)
//                .withRenderingMode(.alwaysTemplate)
//            cell.selectionStyle = .none
//            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
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
    
    @IBAction func messageSendButtonAction(_ sender: Any) {
        //NSUUID().uuidString.lowercased()
        let params: Parameters = [
            "senderDeviceId": self.senderDeviceId!,
            "receiverDeviceId": self.receiverDeviceId!,
            "messageBase64": self.messageTextView.text.base64Encoded() ?? "",
            "messageId": NSUUID().uuidString.lowercased(),
            ]
        print(params)
        let url = UrlMCP.server_base_url + UrlMCP.SendMessageToServer
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            print(response.response?.statusCode ?? "no status code")
            if response.response?.statusCode != 200 {
                self.showAlert(title: "Message", message: "Message sending failed. Please try again later")
            }
            
        }
        
        
//        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
//            .responseJSON { response in
//                print(response.request as Any)  // original URL request
//                print(response.response as Any) // URL response
//                print(response.result.value as Any)   // result of response serialization
//        }
    }
    
}
