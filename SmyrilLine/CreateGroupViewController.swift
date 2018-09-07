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
import Toast_Swift

class CreateGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var allUser = [User]()
    var allUserList = [User]()
    var SelectedUserList = [String:Bool]()
    var activityIndicatorView: UIActivityIndicatorView!
    //var chatSessionObject: chatSessionViewModel?
    
    @IBOutlet weak var allUserCollectionview: UICollectionView!
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        if let allUserArray = chatData.shared.allUser {
            self.allUser = allUserArray
            if chatData.shared.creatingChatGroups == false {
                if let allMemberDevices = chatData.shared.groupChatObject?.memberDevices {
                    for member in allMemberDevices {
                        if let indexOfExistingMember = self.allUser.index(where: ({$0.deviceId == member.deviceId})) {
                            let indexPath = IndexPath(item: indexOfExistingMember, section: 0)
                            self.allUser.remove(at: indexPath.row)
                        }
                    }
                }
            }
            self.allUserList = self.allUser
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.allUser.removeAll()
        
        self.allUser = self.allUserList.filter({ (object: User) -> Bool in
            return (object.name?.base64Decoded()?.lowercased().range(of: searchText.lowercased()) != nil)
        })
        
        if searchText == "" {
            self.allUser.removeAll()
            self.allUser = self.allUserList
        }
        self.allUserCollectionview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.userSearchBar.resignFirstResponder()
    }
    
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
                self.view.makeToast("Group created succesfully.", duration: 2.0, position: .bottom, title: nil, image: nil) { didTap in
                    if didTap {
                        print("completion from tap")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        print("completion without tap")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                self.showErrorAlert(error: error as NSError)
            }
        }
    }
    
    func addMemberToGroup()  {
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = UrlMCP.server_base_url + UrlMCP.addMemberToGroup
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        Alamofire.request(url, method:.post, parameters:self.getParameterDictionaryForAddingMembersToGroup(), headers:headers).responseObject { (response: DataResponse<chatSessionViewModel>) in
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            switch response.result {
            case .success:
                chatData.shared.groupChatObject = response.result.value
                self.view.makeToast("Member added succesfully.", duration: 2.0, position: .bottom, title: nil, image: nil) { didTap in
                    if didTap {
                        print("completion from tap")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        print("completion without tap")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
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
    
    func getParameterDictionaryForAddingMembersToGroup() -> [String: Any] {
        var chatGroupParameterDictionary = [String: Any]()
        chatGroupParameterDictionary["sessionId"] = chatData.shared.groupChatObject?.sessionId
        chatGroupParameterDictionary["callerDeviceId"] = UIDevice.current.identifierForVendor?.uuidString
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
        
        var selectedCount = 0
        for object in self.allUser {
            if self.SelectedUserList[object.deviceId!] != nil, self.SelectedUserList[object.deviceId!]!  {
                selectedCount += 1
                if selectedCount > 1 {
                    break
                }
            }
        }
        
        if chatData.shared.creatingChatGroups {
            if selectedCount > 1 {
                let alerController = UIAlertController(title: "Please enter group name", message: nil, preferredStyle: .alert)
                let saveAction = UIAlertAction(title: "Save", style: .default) { (alertAction) in
                    let groupNameTextField = alerController.textFields![0] as UITextField
                    self.dismiss(animated: true, completion: nil)
                    self.createGroup(name: groupNameTextField.text!)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
                    self.dismiss(animated: true, completion: nil)
                }
                saveAction.isEnabled = false
                alerController.addAction(saveAction)
                alerController.addAction(cancelAction)
                alerController.addTextField { (textField) in
                    textField.placeholder = "Group name"
                    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                        saveAction.isEnabled = textField.text?.count ?? 0 > 0
                    }
                }
                self.present(alerController, animated: true, completion: nil)
            }
            else {
                self.showAlert(title: "Error", message: "Please select at least 2 member to create a group")
            }
        }
        else {
            if selectedCount > 0 {
                self.addMemberToGroup()
            }
            else {
                self.showAlert(title: "Error", message: "Please select member")
            }
        }
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
        let screenHeight = UIScreen.main.bounds.size.height
        switch screenHeight {
        case 480:
            return CGSize(width: 105.0, height: 135.0)
        case 568:
            return CGSize(width: 105.0, height: 135.0)
        case 667,1334:
            // iPhone 6,6s 7,8
            return CGSize(width: 105.0, height: 135.0)
        case 736,2208:
            // iPhone 6+,6s+ 7+,8+
            return CGSize(width: 115.0, height: 135.0)
        case 2436:
            // printf("iPhone X");
            return CGSize(width: 105.0, height: 135.0)
        default:
            return CGSize(width: 105.0, height: 135.0)
        }
        //return CGSize(width: 100, height: 138)
    }
}
