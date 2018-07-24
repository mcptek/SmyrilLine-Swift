//
//  ProfileStatusViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/30/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class ProfileStatusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let profileStatusArray = ["My profile", "Visible to booking", "Public", "Invisible"]
    var currentProfileStatus: String?
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        if let status = UserDefaults.standard.value(forKey: "userVisibilityStatus") as? String {
            self.currentProfileStatus = status
        }
        else {
            self.currentProfileStatus = "Public"
        }

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        UserDefaults.standard.set(self.currentProfileStatus, forKey: "userVisibilityStatus")
        self.uploadProfileVisibility()
    }
    
    
    func uploadProfileVisibility()  {
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let url = UrlMCP.server_base_url + UrlMCP.WebSocketProfilePicImageUpload
        
        Alamofire.request(url, method:.post, parameters:self.retrieveUserProfileDetails(), headers:nil).responseObject { (response: DataResponse<UserProfile>) in
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            switch response.result {
            case .success:
                if let url = response.result.value?.imageUrl {
                    UserDefaults.standard.set(url, forKey: "userProfileImageUrl")
                }
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func retrieveUserProfileDetails() -> [String: Any] {
        
        var imageUrl = String()
        if let url = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String {
            imageUrl = url
        }
        else {
            imageUrl = ""
        }
        
        var userName = ""
        if let profileUserName = UserDefaults.standard.value(forKey: "userName") as? String {
            userName = profileUserName
        }
        else {
            userName = ""
        }
        
        var introInfo = ""
        if let profileUserIntroInfo = UserDefaults.standard.value(forKey: "introInfo") as? String {
            introInfo = profileUserIntroInfo
        }
        else {
            introInfo = ""
        }
        
        var visibilityStatus = 2
        if let status = UserDefaults.standard.value(forKey: "userVisibilityStatus") as? String {
            if status == "Visible to booking" {
                visibilityStatus = 1
            }
            else if status == "Invisible" {
                visibilityStatus = 3
            }
        }
        
        let bookingNumber = UserDefaults.standard.value(forKey: "BookingNo") as! String
        let userSex = UserDefaults.standard.value(forKey: "passengerSex") as! String
        let userNationality = UserDefaults.standard.value(forKey: "passengerNationality") as! String
        let status = 1
        
        
        let params: Parameters = [
            "bookingNo": bookingNumber,
            "Name": userName,
            "description": introInfo,
            "imageUrl": imageUrl,
            "country": userNationality,
            "deviceId": (UIDevice.current.identifierForVendor?.uuidString)!,
            "gender": userSex,
            "status": status,
            "visibility": visibilityStatus,
            "imageBase64": "",
            "phoneType": "iOS",
            ]
        return params
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
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "profileDetails", sender: self)
        }
        else {
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
