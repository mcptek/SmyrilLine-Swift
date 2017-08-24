//
//  ViewControllerExtension.swift
//  QBS-iOS
//
//  Created by Sadrul on 5/8/17.
//  Copyright © 2017 Sadrulnascenia. All rights reserved.
//

import UIKit

public extension UIViewController {
    func showErrorAlert(error: NSError) {
        let title = error.localizedDescription 
        showAlert(title: title, message: error.localizedFailureReason ?? "")
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                                style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayToast(alertMsg : String){
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.gray
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 12)
        toastLabel.textAlignment = NSTextAlignment.center;
        self.view.addSubview(toastLabel)
        
        toastLabel.text = alertMsg
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            
            toastLabel.alpha = 0.0
            
        }, completion: nil)
    }
    
    func convertDateFormatter(date: String) -> Date
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: date)
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let timeStamp = dateFormatter.string(from: date!)
        
        return dateFormatter.date(from: timeStamp)!
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"///this is what you want to convert format
//        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    func retrieveDateFromString(date: String) -> String
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: date)
        
        
        dateFormatter.dateFormat = "dd MMM"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let timeStamp = dateFormatter.string(from: date!)
        
        return timeStamp
    }

}