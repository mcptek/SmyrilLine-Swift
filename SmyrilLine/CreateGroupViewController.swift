//
//  CreateGroupViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class CreateGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var allUser = [User]()
    var SelectedUserList = [String:Bool]()
    var activityIndicatorView: UIActivityIndicatorView!
    var chatSessionObject: chatSessionViewModel?
    
    @IBOutlet weak var allUserCollectionview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
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

    func createGroup(name: String)  {
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = UrlMCP.server_base_url + UrlMCP.createNewChatGroup
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        Alamofire.request(url, method:.post, parameters:self.getParameterDictionaryFor(groupName: name), headers:headers).responseObject { (response: DataResponse<chatSessionViewModel>) in
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            switch response.result {
            case .success:
                self.chatSessionObject = response.result.value
                print(self.chatSessionObject?.groupName ?? "No group name Found")
            case .failure(let error):
                self.showErrorAlert(error: error as NSError)
            }
        }
    }
    
    func getParameterDictionaryFor(groupName: String) -> [String: Any] {
        var chatGroupParameterDictionary = [String: Any]()
        chatGroupParameterDictionary["SessionId"] = ""
        chatGroupParameterDictionary["GroupName"] = groupName
        chatGroupParameterDictionary["OwnerDeviceId"] = UIDevice.current.identifierForVendor?.uuidString
        var index = 0
        for object in self.allUser {
            if self.SelectedUserList[object.deviceId!] != nil, self.SelectedUserList[object.deviceId!]!  {
                chatGroupParameterDictionary["MemberDeviceIds[" + String(index) + "]"] = object.deviceId
                index += 1
            }
        }
        return chatGroupParameterDictionary
    }
    
    
    @IBAction func barButtonAction(_ sender: Any) {
        
        let alerController = UIAlertController(title: "Please enetr group name", message: "", preferredStyle: .alert)
        alerController.addTextField { (textField) in
            textField.placeholder = "Group name"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { (alertAction) in
            let groupNameTextField = alerController.textFields![0] as UITextField
            if groupNameTextField.text?.count == 0 {
                
            }
            else {
                self.dismiss(animated: true, completion: nil)
                self.createGroup(name: groupNameTextField.text!)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alerController.addAction(saveAction)
        alerController.addAction(cancelAction)
        self.present(alerController, animated: true, completion: nil)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.allUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allUser", for: indexPath) as! AllUserCollectionViewCell
        if self.SelectedUserList[self.allUser[indexPath.row].deviceId!] != nil {
            if self.SelectedUserList[self.allUser[indexPath.row].deviceId!]! {
                cell.userSelectionImageview.image = UIImage.init(named: "settingSelect")
            }
            else {
                cell.userSelectionImageview.image = nil
            }
        }
        else {
            cell.userSelectionImageview.image = nil
        }
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
        cell.userImageView.clipsToBounds = true
        if let name = self.allUser[indexPath.row].name {
            if let decodedname = name.base64Decoded() {
                cell.usernameLabel.text = decodedname
            }
            else {
                cell.usernameLabel.text = name
            }
        }
        else {
            cell.usernameLabel.text = "No name Found"
        }
        
        if let imageUrlStr = self.allUser[indexPath.row].imageUrl
        {
            cell.userImageView.sd_setShowActivityIndicatorView(true)
            cell.userImageView.sd_setIndicatorStyle(.gray)
            cell.userImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
        }
        else {
            cell.userImageView.image = UIImage.init(named: "UserPlaceholder")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if self.SelectedUserList[self.allUser[indexPath.row].deviceId!] != nil {
            if self.SelectedUserList[self.allUser[indexPath.row].deviceId!]! {
                self.SelectedUserList[self.allUser[indexPath.row].deviceId!] = false
            }
            else {
                self.SelectedUserList[self.allUser[indexPath.row].deviceId!] = true
            }
        }
        else {
            self.SelectedUserList[self.allUser[indexPath.row].deviceId!] = true
        }
        let userIndexPath = IndexPath.init(row: indexPath.row, section: 0)
        self.allUserCollectionview.reloadItems(at: [userIndexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(8.0, 0.0, 8.0, 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100, height: 138)
    }
}