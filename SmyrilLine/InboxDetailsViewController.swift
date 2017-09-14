//
//  InboxDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/14/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class InboxDetailsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var messageDetailsTableview: UITableView!
    var messageObject: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        let navigationBar = navigationController!.navigationBar
        navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        
        self.messageDetailsTableview.estimatedRowHeight = 250
        self.messageDetailsTableview.rowHeight = UITableViewAutomaticDimension
        self.messageDetailsTableview.reloadData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Inbox"
        self.navigationController?.navigationBar.isHidden = false
        let navigationBar = navigationController!.navigationBar
        navigationBar.attachToScrollView(self.messageDetailsTableview)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.navigationBar.backItem?.title = ""
        self.makeMessageRead()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationBar = navigationController!.navigationBar
        navigationBar.reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func makeMessageRead()  {
        if #available(iOS 10.0, *) {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.updateMessageStatusWithMessageId(messageId: (self.messageObject?.messageId)!)
            self.messageDetailsTableview.reloadData()
        } else {
            // Fallback on earlier versions
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inboxDetailsCell", for: indexPath) as! InboxDetailsTableViewCell
        cell.titleLabel.text = self.messageObject?.messageTitle
        let date = NSDate(timeIntervalSince1970: TimeInterval((messageObject?.messageTime)!))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy hh:mm a"
        cell.messageDateLabel.text = dateFormatter.string(from: date as Date)
        if (self.messageObject?.messageUrlStr?.characters.count)! > 0
        {
            cell.messageImageView.isHidden = false
            cell.messageImageView.sd_setShowActivityIndicatorView(true)
            cell.messageImageView.sd_setIndicatorStyle(.gray)
            cell.messageImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + (self.messageObject?.messageUrlStr)!), placeholderImage: UIImage.init(named: ""))
        }
        else
        {
            cell.messageImageView.isHidden = true
        }
        cell.messageDetailsLabel.text = self.messageObject?.messageDetails
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
