//
//  BookingLogInViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class BookingLogInViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var bookingNoTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print(UserDefaults.standard.bool(forKey: "GuideScreen"))
        if UserDefaults.standard.bool(forKey: "GuideScreen") == false {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "pageContainerView")
            self.present(vc!, animated: true, completion: nil)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.bookingNoTextField {
            self.lastnameTextField.becomeFirstResponder()
        }else {
            self.lastnameTextField.resignFirstResponder()
        }
        return true
    }
    
}
