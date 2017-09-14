//
//  InboxViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/13/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    var messageArray:[Message]?
    var messageObject: Message?
    @IBOutlet weak var inboxTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        let navigationBar = navigationController!.navigationBar
        navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        
        self.inboxTableview.estimatedRowHeight = 150
        self.inboxTableview.rowHeight = UITableViewAutomaticDimension

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.navigationBar.backItem?.title = ""
        self.newMessageReceived()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(newMessageReceived), name: Notification.Name("InboxNotification"), object: nil)
        self.title = "Inbox"
        self.navigationController?.navigationBar.isHidden = false
        let navigationBar = navigationController!.navigationBar
        navigationBar.attachToScrollView(self.inboxTableview)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: Notification.Name("InboxNotification"), object: nil)
        let navigationBar = navigationController!.navigationBar
        navigationBar.reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            cell.messageReadUnreadStatusLabel.textColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        }
        else
        {
             cell.messageReadUnreadStatusLabel.textColor = UIColor.clear
        }
        
        let date = NSDate(timeIntervalSince1970: TimeInterval((messageObject?.messageTime)!))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        cell.messageDateLabel.text = dateFormatter.string(from: date as Date)
        
        
//        cell.destinationName.text = self.destinaionArray?[indexPath.section].name
//        if let imageUrlStr = self.destinaionArray?[indexPath.section].imageUrl
//        {
//            cell.destinationImageView.sd_setShowActivityIndicatorView(true)
//            cell.destinationImageView.sd_setIndicatorStyle(.gray)
//            cell.destinationImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
//            
//        }
        cell.selectionStyle = .none
        return cell
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

}
