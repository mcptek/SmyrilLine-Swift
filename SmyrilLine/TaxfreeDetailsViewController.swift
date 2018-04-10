//
//  TaxfreeDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/4/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import SDWebImage
import MXParallaxHeader
import ReachabilitySwift
import Alamofire

class TaxfreeDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var productDetailsTableview: UITableView!
    
    var productName: String?
    var productPrice: String?
    var productImageUrl: String?
    var productDetails: String?
    var productattatchFileUrlPath: String?
    var productAttatchFilName: String?
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var myHeaderView: TaxfreeHeaderDetailsHeader!
    var scrollView: MXScrollView!
    var headerCurrentStatus = 0
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var downloadBgView: UIView!
    @IBOutlet weak var downloadContainerView: UIView!
    @IBOutlet weak var downloadProgressbar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeHeaderDetailsHeader", owner: self, options: nil)?.first as? UIView as! TaxfreeHeaderDetailsHeader
        self.productDetailsTableview.parallaxHeader.view = self.myHeaderView
        self.productDetailsTableview.parallaxHeader.height = 250
        self.productDetailsTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.productDetailsTableview.parallaxHeader.minimumHeight = 50
        
        //self.productDetailsTableview.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.productDetailsTableview.tableFooterView = UIView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let imageUrlStr = self.productImageUrl
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            self.myHeaderView.productImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.productImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.productImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        if (self.productattatchFileUrlPath) != nil && self.productattatchFileUrlPath?.count != 0
        {
            self.downloadButton.isEnabled = true
            self.downloadButton.tintColor = .white
        }
        else {
            self.downloadButton.isEnabled = false
            self.downloadButton.tintColor = .clear
        }
        self.downloadBgView.isHidden = true
        self.downloadContainerView.isHidden = true
        
        self.downloadContainerView.layer.cornerRadius = 3
        self.downloadContainerView.layer.masksToBounds = true
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSessionDetails")
        self.backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        self.downloadProgressbar.setProgress(0.0, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgView.isHidden = true
            self.downloadContainerView.isHidden = true
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reachabilityChanged"), object: nil)
        self.backgroundSession.invalidateAndCancel()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reachabilityChanged() {
        
        if ReachabilityManager.shared.reachabilityStatus == .notReachable {
            if self.downloadTask != nil{
                self.downloadTask.cancel()
                self.downloadBgView.isHidden = true
                self.downloadContainerView.isHidden = true
                self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
            }
        }
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        let reachibility = Reachability()!
        if reachibility.isReachable {
            if var urlPath = self.productattatchFileUrlPath {
                if self.downloadBgView.isHidden == true {
                    urlPath = urlPath.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                    let url = URL(string: UrlMCP.server_base_url + urlPath)!
                    self.downloadTask = self.backgroundSession.downloadTask(with: url)
                    self.downloadTask.resume()
                    self.downloadBgView.isHidden = false
                    self.downloadContainerView.isHidden = false
                }
            }
        }
        else {
            self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
        }
    }
    
    @IBAction func downloadCancelButtonAction(_ sender: Any) {
        if self.downloadTask != nil{
            self.downloadTask.cancel()
            self.downloadBgView.isHidden = true
            self.downloadContainerView.isHidden = true
        }
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as! TaxfreeDetailsPriceTableViewCell
            if let productName = self.productName
            {
                cell.productNameLabel.text = productName
            }
            
            self.productPrice = self.productPrice?.replacingOccurrences(of: "€", with: "", options: .literal, range: nil)
            if let priceObject = self.productPrice
            {
                var price = priceObject.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
                //price = "€" + price
                if price.characters.contains(",") {
                    let splittedStringsArray = price.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
                    if let firstString = splittedStringsArray.first, let secondString = splittedStringsArray.last
                    {
                        let numericPart = String(describing: firstString)
                        let fractionPart = String(describing: secondString)
                        let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                        let scriptFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
                        let stringwithSquare = numericPart.attributedStringWithSuperscript(fractionPart, mainStringFont: mainFont, subStringFont: scriptFont, offSetFromBaseLine: 10)
                        cell.productPriceLabel.attributedText = stringwithSquare
                    }
                    else
                    {
                        let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                        cell.productPriceLabel.text = price
                        cell.productPriceLabel.font = mainFont
                        
                    }
                }
                else {
                    let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                    cell.productPriceLabel.text = price
                    cell.productPriceLabel.font = mainFont
                }
            }
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productDetailsCell", for: indexPath) as! TaxfreeProductDetailsTableViewCell
            if let productDetails = self.productDetails
            {
                cell.productDetailsLabel.text = productDetails
            }
            else
            {
                cell.productDetailsLabel.text = nil
            }
            
            let LineLengthOfLabel = self.countLabelLines(label: cell.productDetailsLabel) - 1
            if LineLengthOfLabel <= 2
            {
                cell.seeMoreButton.isHidden = true
                cell.seeMoreButtonHeightConstraint.constant = 0
            }
            else
            {
                cell.seeMoreButton.isHidden = false
                cell.seeMoreButtonHeightConstraint.constant = 30
                if self.headerCurrentStatus == 2
                {
                    cell.productDetailsLabel.numberOfLines = 0
                    cell.seeMoreButton.setTitle("See More", for: .normal)
                }
                else
                {
                    cell.productDetailsLabel.numberOfLines = 2
                    cell.seeMoreButton.setTitle("See More", for: .normal)
                }
                cell.seeMoreButton.addTarget(self, action: #selector(headerSeeMoreOrLesssButtonAction(_:)), for: .touchUpInside)
            }
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeOrderCell", for: indexPath) as! PlaceOrderTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
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
    
    func headerSeeMoreOrLesssButtonAction(_ sender : UIButton)  {
        self.headerCurrentStatus = 2
        self.productDetailsTableview.reloadData()
        
    }
    
    func showFileWithPath(path: String){
        let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
        if isFileFound == true{
            let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
            viewer.delegate = self
            viewer.presentPreview(animated: true)
        }
    }
    
    //MARK: URLSessionDownloadDelegate
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        var fileName = ""
        if let name = self.productAttatchFilName {
            fileName =  "/" + name
        }
        else {
            fileName = "/file.pdf"
        }
        
        //let name = "/" + self.shopObject?.attatchFileName
        //        if name.range(of:".pdf") == nil {
        //            name = name + ".pdf"
        //        }
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat(fileName))
        self.downloadBgView.isHidden = true
        self.downloadContainerView.isHidden = true
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            showFileWithPath(path: destinationURLForFile.path)
        }
        else{
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                // show file
                showFileWithPath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    // 2
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        self.downloadProgressbar.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        self.downloadTask = nil
        self.downloadProgressbar.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully in details pge")
        }
        self.downloadBgView.isHidden = true
        self.downloadContainerView.isHidden = true
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }


}
