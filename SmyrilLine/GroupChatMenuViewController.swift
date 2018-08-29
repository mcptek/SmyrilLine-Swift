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

class GroupChatMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let menuArray = ["Add member", "Rename group", "Delete group"]
    var activityIndicatorView: UIActivityIndicatorView!
    var groupChatObject: chatSessionViewModel?
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupMenuCell", for: indexPath)
        cell.textLabel?.text = self.menuArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("0")
        case 1:
            self.getNewGroupName()
        default:
            print("default")
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
        let alerController = UIAlertController(title: "Enetr new group name", message: nil, preferredStyle: .alert)
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
            textField.text = self.groupChatObject?.groupName
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = (textField.text?.count ?? 0 > 0) && (textField.text != self.groupChatObject?.groupName)
            }
        }
        self.present(alerController, animated: true, completion: nil)
    }
    
    func renameGroup(name: String)  {
        var chatGroupParameterDictionary = [String: Any]()
        chatGroupParameterDictionary["SessionId"] = self.groupChatObject?.sessionId
        chatGroupParameterDictionary["GroupName"] = name
        chatGroupParameterDictionary["callerDeviceId"] = UIDevice.current.identifierForVendor?.uuidString
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let url = UrlMCP.server_base_url + UrlMCP.renameChatGroup
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        Alamofire.request(url, method:.post, parameters:chatGroupParameterDictionary, headers:headers).responseObject { (response: DataResponse<chatSessionViewModel>) in
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            switch response.result {
            case .success:
                print("Success")
            case .failure(let error):
                self.showErrorAlert(error: error as NSError)
            }
        }
    }
    

}
