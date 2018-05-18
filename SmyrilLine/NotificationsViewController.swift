//
//  NotificationsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 18/5/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var messageArray:[Message]?
    var messageObject: Message?
    
    @IBOutlet weak var inboxTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = NSLocalizedString("Notification", comment: "")
        //self.title = "Inbox"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        //let navigationBar = navigationController!.navigationBar
        //navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        
        self.inboxTableview.estimatedRowHeight = 150
        self.inboxTableview.rowHeight = UITableViewAutomaticDimension
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
    

    func newMessageReceived()  {
        if #available(iOS 10.0, *) {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            self.messageArray = appDelegate?.retrieveAllInboxMessages()
            self.inboxTableview.reloadData()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.messageArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
        vw.backgroundColor = UIColor.clear
        return vw
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        return vw
    }
}
