//
//  ChatContainerViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/21/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import NextGrowingTextView

class ChatContainerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var inputContainerviewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    @IBOutlet weak var chatTableView: UITableView!
    private var isVisibleKeyboard = true
    var messageArray =  [ChatMessageMOdel]()
    var messageObject:  ChatMessageMOdel?
    
    override func viewDidLoad() { 
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
                self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.growingTextView.textView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Please enter your message here",
                                                                            attributes: [NSFontAttributeName: self.growingTextView.textView.font!,
                                                                                         NSForegroundColorAttributeName: UIColor.gray
            ]
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let messageObject = ChatMessageMOdel.init(message: "Hello iOS device..", messageType: 0, time: "", status: 1)
        self.messageArray.append(messageObject)
        self.chatTableView.reloadData()
        print(self.messageArray )
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
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //key point 0,
                self.inputContainerviewBottomHeight.constant =  0
                //textViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.inputContainerviewBottomHeight.constant = keyboardHeight - 45
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.messageObject = self.messageArray[indexPath.row]
        if self.messageObject?.messageType == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "incomingMessageCell", for: indexPath) as! IncomingMessageTableViewCell
            cell.bubbleImageView.image = UIImage(named: "chat_bubble_received")?
                .resizableImage(withCapInsets:
                    UIEdgeInsetsMake(17, 21, 17, 21),
                                resizingMode: .stretch)
                .withRenderingMode(.alwaysTemplate)
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "outGoingMessagingCell", for: indexPath) as! OutgoingMessageTableViewCell
            cell.bubbleImageView.image = UIImage(named: "chat_bubble_sent")?
                .resizableImage(withCapInsets:
                    UIEdgeInsetsMake(17, 21, 17, 21),
                                resizingMode: .stretch)
                .withRenderingMode(.alwaysTemplate)
            cell.selectionStyle = .none
            return cell
        }
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
    
    @IBAction func sendLocalMessageButtonAction(_ sender: Any) {
        let messageObject = ChatMessageMOdel.init(message: self.growingTextView.textView.text, messageType: 1, time: "", status: 1)
        self.messageArray.append(messageObject)
        self.growingTextView.textView.text = nil
        self.chatTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        
        return vw
    }
}
