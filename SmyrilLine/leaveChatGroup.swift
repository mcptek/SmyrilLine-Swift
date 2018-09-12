//
//  GroupChatMenuViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 28/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import Toast_Swift
import ObjectMapper

class GroupChatMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let menuArray = ["Add member", "Rename group", "Delete group"]
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = chatData.shared.groupChatObject?.groupName
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroup), name: NSNotification.Name(rawValue: "groupUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(groupDeleted), name: NSNotification.Name(rawValue: "groupDeleted"), object: nil)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //self.view.isUserInteractionEnabled = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateGroup(_ notification: Notification) {
        if let dic = notification.userInfo as? [String: Any] {
            if let myDic = dic["newMessage"] as? [String: Any] {
                if myDic["sessionId"] as? String == chatData.shared.groupChatObject?.sessionId {
                    if let objectData = Mapper<chatSessionViewModel>().map(JSON: myDic) {
                        if objectData.groupName != chatData.shared.groupChatObject?.groupName {
                            // Group name updated
                            self.view.makeToast("Group name updated.", duration: 2.0, position: .bottom)
                            self.title = objectData.groupName
                        }
                        else if (objectData.memberDevices?.count)! > (chatData.shared.groupChatObject?.memberDevices?.count)! {
                            // Member updated
                            self.view.makeToast("New member added.", duration: 2.0, position: .bottom)
                        }
                        else if (objectData.memberDevices?.count)! < (chatData.shared.groupChatObject?.memberDevices?.count)! {
                            // Member left
                            self.view.makeToast("Member left.", duration: 2.0, position: .bottom)
                        }
                        chatData.shared.groupChatObject = objectData
                    }
                }
            }
        }
    }
    
    func groupDeleted(_ notification: Notification) {
        var toastMessage = "Group is deleted."
        if let dic = notification.userInfo as? [String: Any] {
            if let allGroupListArray = dic["newMessage"] as? [chatSessionViewModel] {
                for object in chatData.shared.allGroups! {
                    if allGroupListArray.index(where: { $0.sessionId == object.sessionId }) == nil {
                        toastMessage = "Group " + object.groupName! + " is deleted."
                        break
                    }
                }
                chatData.shared.allGroups = allGroupListArray
                self.view.isUserInteractionEnabled = false
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                self.view.makeToast(toastMessage, duration: 2.0, position: .bottom, title: nil, image: nil) { didTap in
                    if didTap {
                        self.view.isUserInteractionEnabled = true
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self.view.isUserInteractionEnabled = true
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupMenuCell", for: indexPath)
        if indexPath.row == 2 {
            if chatData.shared.groupChatObject?.ownerDeviceId == UIDevice.current.identifierForVendor?.uuidString {
                cell.textLabel?.text = "Delete group"
            }
            else {
                cell.textLabel?.text = "Leave group"
            }
        }
        else {
            cell.textLabel?.text = self.menuArray[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            chatData.shared.creatingChatGroups = false
            self.performSegue(withIdentifier: "addMember", sender: self)
        case 1:
            self.getNewGroupName()
        default:
            if chatData.shared.groupChatObject?.ownerDeviceId == UIDevice.current.identifierForVendor?.uuidString {
                self.deleteGroup()
            }
            else {
                self.leaveGroup()
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
    
    func getNewGroupName() {
        let alerController = UIAlertController(title: "Enter new group name", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let groupNameTextField = alerController.textFields![0] as UITextField
            self.dismiss(animated: true, completion: nil)
            self.renameGroup(name: groupNameTextField.text!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        saveAction.isEnabled = false
        alerController.addAction(saveAction)
        alerController.addAction(cancelAction)
        alerController.addTextField { (textField) in
            textField.placeholder = "Group name"
            textField.text = chatData.shared.groupChatObject?.groupName
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = (textField.text?.count ?? 0 > 0) && (textField.text != chatData.shared.groupChatObject?.groupName)
            }
        }
        self.present(alerController, animated: true, completion: nil)
    }
    
    func renameGroup(name: String)  {
        var chatGroupParameterDictionary = [String: Any]()
        chatGroupParameterDictionary["SessionId"] = chatData.shared.groupChatObject?.sessionId
        chatGroupParameterDictionary["GroupName"] = name
        chatGroupParameterDictionary["callerDeviceId"] = UIDevice.current.identifierForVendor?.uuidString
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = UrlMCP.server_base_url + UrlMCP.renameChatGroup
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        Alamofire.request(url, method:.post, parameters:chatGroupParameterDictionary, headers:headers).responseObject { (response: DataResponse<chatSessionViewModel>) in
            self.activityIndicatorView.stopAnimating()
            
            switch response.result {
            case .success:
                chatData.shared.groupChatObject = response.result.value
                self.title = chatData.shared.groupChatObject?.groupName
                self.view.makeToast("Group renamed succesfully.", duration: 2.0, position: .bottom, title: nil, image: nil) { didTap in
                    if didTap {
                        print("completion from tap")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        print("completion without tap")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                self.view.isUserInteractionEnabled = true
                self.showErrorAlert(error: error as NSError)
            }
        }
    }
    
    func deleteGroup()  {
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = UrlMCP.server_base_url + UrlMCP.deleteChatGroup
        var chatGroupParameterDictionary = [String: Any]()
        chatGroupParameterDictionary["SessionId"] = chatData.shared.groupChatObject?.sessionId
        chatGroupParameterDictionary["OwnerDeviceId"] = chatData.shared.groupChatObject?.ownerDeviceId
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        Alamofire.request(url, method: .post, parameters: chatGroupParameterDictionary, encoding: URLEncoding.default, headers: headers)
            .responseArray { (response: DataResponse<[chatSessionViewModel]>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result {
                case .success:
                    let forecastArray = response.result.value
                    if let UserList = forecastArray {
                        chatData.shared.allGroups = UserList
                        self.view.makeToast("Group deleted succesfully.", duration: 2.0, position: .bottom, title: nil, image: nil) { didTap in
                            if didTap {
                                print("completion from tap")
                                self.navigationController?.popToRootViewController(animated: true)
                            } else {
                                print("completion without tap")
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                    else {
                        self.view.isUserInteractionEnabled = true
                        self.showAlert(title: "Message", message: "No user list found")
                    }
                case .failure(let error):
                    self.view.isUserInteractionEnabled = true
                    self.showErrorAlert(error: error as NSError)
                }
        }
    }
    
    func leaveGroup()  {
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let params: Parameters = [
            "SessionId": chatData.shared.groupChatObject?.sessionId ?? "",
            "CallerDeviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            ]
        let url = UrlMCP.server_base_url + UrlMCP.leaveChatGroup
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            if response.response?.statusCode == 200 {
                self.view.makeToast("Group left succesfully.", duration: 2.0, position: .bottom, title: nil, image: nil) { didTap in
                    if didTap {
                        print("completion from tap")
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        print("completion without tap")
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
            }
        }
    }

}
