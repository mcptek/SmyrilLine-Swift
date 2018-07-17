//
//  BookingLogInViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit
import Alamofire

class BookingLogInViewController: UIViewController, UITextFieldDelegate, NSURLConnectionDelegate, XMLParserDelegate {

    @IBOutlet weak var bookingNoTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var viewBookingButton: UIButton!
    
    var activityIndicatorView: UIActivityIndicatorView!
    var parser = XMLParser()
    var currentParsingElement:String = ""
    var bookingXMLString:String = ""
    var bookingInfo: [String:Any]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        self.viewBookingButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.currentParsingElement = ""
        self.bookingXMLString = ""
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //if segue.identifier == "bookingInfo" {
            //let vc = segue.destination as! MySmyrilLineViewController
            //vc.bookingData = se
            
        //}
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.bookingNoTextField {
            self.lastnameTextField.becomeFirstResponder()
        }else {
            self.lastnameTextField.resignFirstResponder()
        }
        return true
    }
 
    @IBAction func bookingButtonAction(_ sender: Any) {
        
        let soapMessage =  "<?xml version='1.0' encoding='UTF-8'?><SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ns1='http://novedas-sosy.de/'><SOAP-ENV:Body><ns1:GetBookingData><ns1:Name>\(self.lastnameTextField.text!)</ns1:Name><ns1:BookNo>\(self.bookingNoTextField.text!)</ns1:BookNo></ns1:GetBookingData></SOAP-ENV:Body></SOAP-ENV:Envelope>"
        let urlString = "http://booking.smyrilline.com:8080/SmyrilSVC.asmx?wsdl"
        let url = URL(string: urlString)
        
        let msgLength = soapMessage.count
        var request = URLRequest(url: url!)
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("http://novedas-sosy.de/GetBookingData", forHTTPHeaderField: "SOAPAction")
        request.setValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "dssddsd")// some fundamental network error
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                return
            }
            
            self.parser = XMLParser(data: data)
            self.parser.delegate = self
            let success:Bool = self.parser.parse()
            if success {
                print("success")
            } else {
                print("parse failure!")
            }
        }
        task.resume()
    }
    
    //MARK:- XML Delegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentParsingElement = elementName
        print(elementName)
        if elementName == "GetBookingDataResult" {
            print("Started parsing...")
             DispatchQueue.main.async {
                self.activityIndicatorView.startAnimating()
                self.view.isUserInteractionEnabled = false
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let foundedChar = string.trimmingCharacters(in:NSCharacterSet.whitespacesAndNewlines)
        
        
        if (!foundedChar.isEmpty) {
            if currentParsingElement == "GetBookingDataResult" {
                bookingXMLString += foundedChar
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "GetBookingDataResult" {
            print("Ended parsing...")
            let jsonData = self.bookingXMLString.data(using: .utf8)!
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
            if let dic = json as? [String:Any] {
                self.bookingInfo = dic
            }
            
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "bookingInfo") as! MySmyrilLineViewController
            vc.bookingData = self.bookingInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parseErrorOccurred: \(parseError)")
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
}
