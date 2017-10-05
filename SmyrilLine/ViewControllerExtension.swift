//
//  ViewControllerExtension.swift
//  QBS-iOS
//
//  Created by Sadrul on 5/8/17.
//  Copyright © 2017 Sadrulnascenia. All rights reserved.
//

import UIKit


public extension String{
    
    func attributedStringWithSubscript(_ subString: String, mainStringFont: UIFont, subStringFont: UIFont) -> NSMutableAttributedString {
        
        let fullString = self+subString
        
        let reqLocation = self.characters.count
        
        let reqLangth = subString.characters.count
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: fullString, attributes: [NSFontAttributeName:mainStringFont])
        
        attString.setAttributes([NSFontAttributeName:subStringFont,NSBaselineOffsetAttributeName:0], range: NSRange(location:reqLocation,length:reqLangth))
        
        return attString
        
    }
    
    func attributedStringWithSuperscript(_ superString: String, mainStringFont: UIFont, subStringFont: UIFont, offSetFromBaseLine offSet: CGFloat) -> NSMutableAttributedString {
        
        let fullString = self+superString
        
        let reqLocation = self.characters.count
        
        let reqLangth = superString.characters.count
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: fullString, attributes: [NSFontAttributeName:mainStringFont])
        
        attString.setAttributes([NSFontAttributeName:subStringFont,NSBaselineOffsetAttributeName:offSet], range: NSRange(location:reqLocation,length:reqLangth))
        
        return attString
        
    }
    
}

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
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 130, y: self.view.frame.size.height-100, width: 250, height: 45))
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
    
    func countLabelLines(label: UILabel) -> Int {
        //  Call self.layoutIfNeeded() //if your view uses auto layout
        if label.text != nil
        {
            let myText = label.text! as NSString
            let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
            let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
            return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
        }
        else
        {
            return 0
        }
    }

}
