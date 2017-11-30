//
//  ProfileStatusViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/30/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class ProfileStatusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let profileStatusArray = ["My profile", "Visible to boking", "Public", "Invisible"]
    var currentProfileStatus: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let status = UserDefaults.standard.value(forKey: "userVisibilityStatus") as? String {
            self.currentProfileStatus = status
        }
        else {
            self.currentProfileStatus = "Public"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(self.currentProfileStatus, forKey: "userVisibilityStatus")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profileStatusArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileVisibilityStatusTableViewCell
        cell.textLabel?.text = self.profileStatusArray[indexPath.row]
        if indexPath.row == 0 {
            cell.accessoryType = .none
            cell.editLabel.isHidden = false
        }
        else {
            cell.editLabel.isHidden = true
            if self.profileStatusArray[indexPath.row] == self.currentProfileStatus {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 0 {
            self.currentProfileStatus = self.profileStatusArray[indexPath.row]
        }
        tableView.reloadData()
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
