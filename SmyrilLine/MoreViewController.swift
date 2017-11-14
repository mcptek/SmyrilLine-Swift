//
//  MoreViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/25/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var moreTableview: UITableView!
    let itemArray = ["Ship Tracker", "Destination", "Ship Info", "Help", "Settings", "Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        self.moreTableview.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.moreTableview.tableFooterView = UIView()
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

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreTableCell", for: indexPath)
        cell.textLabel?.text = self.itemArray[indexPath.row]
        cell.imageView?.image = UIImage.init(named: self.itemArray[indexPath.row])
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "shipTracker", sender: self)
        case 1:
            self.performSegue(withIdentifier: "destination", sender: self)
        case 2:
            self.performSegue(withIdentifier: "shipInfo", sender: self)
        case 3:
            self.performSegue(withIdentifier: "help", sender: self)
        case 4:
//            self.performSegue(withIdentifier: "settings", sender: self)
            self.performSegue(withIdentifier: "setting", sender: self)
        default:
            print("LogOut Action")
        }
    }
    
}
