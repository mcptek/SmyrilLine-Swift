//
//  HelpViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/12/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var helpScrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var clientIdLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myWebview: UIWebView!
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = self.myWebview.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        //self.view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        self.navigationItem.title = NSLocalizedString("Help", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.LoadHelpViewContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func LoadHelpViewContent()  {
        self.appVersionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.clientIdLabel.text = UIDevice.current.identifierForVendor?.uuidString
        
        self.myWebview.scrollView.isScrollEnabled = false
        self.myWebview.delegate = self
        self.myWebview.loadHTMLString("<html><body><p><strong>Wi-Fi Connectivity</strong></p><p>Remember to connect to our local Wi-Fi network to take full advantage of our Smyril Line APP.</p><p><strong>Ship Tracker</strong></p><p>Ship Tracker gives you a quick glimps of next port, previous port, time of arrival and path of journey.</p><p><strong>Coupons and Offers</strong></p><p>You can see all the available offers at a glance in this section. Hurry up before the promotional offers expire.</p><p><strong>Restaurants</strong></p><p>You will find list of all the restaurants in our ship and their menu. Enjoy delicious food at our cozy restaurants.</p><p><strong>About the Ship</strong></p><p>You will find all the info about Norröna in this section.</p></body></html>", baseURL: nil)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicatorView.startAnimating()
    }
    //[self.myWebview stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"]
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicatorView.stopAnimating()
        self.myWebview.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.fontFamily =\"-apple-system\"")
        let contentHeigt = self.myWebview.stringByEvaluatingJavaScript(from: "document.body.offsetHeight;")
        self.webViewHeightConstraint.constant = webView.scrollView.contentSize.height
        self.containerHeightConstraint.constant =  self.webViewHeightConstraint.constant + self.clientIdLabel.bounds.size.height + 42 + 20.5
        print(self.webViewHeightConstraint.constant,Int(contentHeigt!)! )
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndicatorView.stopAnimating()
        self.showErrorAlert(error: error as NSError)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
