//
//  EditProfileViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 12/7/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    var headerStr: String?
    
    
    @IBOutlet weak var profileEditTextField: UITextField!
    @IBOutlet weak var headerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.headerNameLabel.text = headerStr
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
        if let text = self.profileEditTextField.text {
            if headerStr == "Set user name" {
                UserDefaults.standard.set(text, forKey: "userName")
            }
            else {
                UserDefaults.standard.set(text, forKey: "introInfo")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
