//
//  EditProfileViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/7/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController,UITextFieldDelegate {

    var headerStr: String?
    
    
    @IBOutlet weak var introTextView: UITextView!
    @IBOutlet weak var profileEditTextField: UITextField!
    @IBOutlet weak var headerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        var str = "Hello, playground"
//        print("Original string: \"\(str)\"")
//
//        if let base64Str = str.base64Encoded() {
//            print("Base64 encoded string: \"\(base64Str)\"")
//            if let trs = base64Str.base64Decoded() {
//                print("Base64 decoded string: \"\(trs)\"")
//                print("Check if base64 decoded string equals the original string: \(str == trs)")
//            }
//        }
        
        self.headerNameLabel.text = headerStr
        if headerStr == "Username" {
            self.profileEditTextField.placeholder = "Enter username"
            if let profileUserName = UserDefaults.standard.value(forKey: "userName") as? String {
                if let username = profileUserName.base64Decoded() {
                    self.profileEditTextField.text = username
                }
                else {
                    self.profileEditTextField.text = profileUserName
                }
            }
        }
        else {
            self.profileEditTextField.placeholder = "Write about yourself."
            if let introInfo = UserDefaults.standard.value(forKey: "introInfo") as? String {
                if let intro = introInfo.base64Decoded() {
                    self.profileEditTextField.text = intro
                }
                else {
                    self.profileEditTextField.text = introInfo
                }
            }
        }
        
         self.hideKeyboardWhenTappedAround()
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
    @IBAction func saveButtonAction(_ sender: Any) {
        self.profileEditTextField.resignFirstResponder()
        var message = ""
        if headerStr == "Username" {
            message = "Please add a username"
        }
        else {
            message = "Please add a intro info"
        }
        
        if let text = self.profileEditTextField.text, !text.isEmpty {
            if headerStr == "Username" {
                if let base64Str = text.base64Encoded() {
                    UserDefaults.standard.set(base64Str, forKey: "userName")
                }
                else {
                    UserDefaults.standard.set(text, forKey: "userName")
                }
                //UserDefaults.standard.set(text, forKey: "userName")
            }
            else {
                if let base64Str = text.base64Encoded() {
                    UserDefaults.standard.set(base64Str, forKey: "introInfo")
                }
                else {
                    UserDefaults.standard.set(text, forKey: "introInfo")
                }
                //UserDefaults.standard.set(text, forKey: "introInfo")
            }
            let alertController = UIAlertController(title: nil, message: "Profile updated", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.dismiss(animated: true, completion: nil)
            }
            // Add the actions
            alertController.addAction(okAction)
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
            }
            // Add the actions
            alertController.addAction(okAction)
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.saveButtonAction(textField)
        if textField == self.profileEditTextField {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        if headerStr == "Username" {
            return newLength <= 15
        }
        else {
            return newLength <= 60
        }
    }
    
}
