//
//  ShipInfoDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 10/3/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import SDWebImage
import MXParallaxHeader
import ReachabilitySwift

class ShipInfoDetailsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, URLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate {

    var shipInfoCategoryObject: GeneralCategory?
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    
    @IBOutlet weak var shipInfoCategoryTableview: UITableView!
    @IBOutlet weak var downloadBgview: UIView!
    @IBOutlet weak var downloadContainerView: UIView!
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = self.shipInfoCategoryObject?.name
        
        self.shipInfoCategoryTableview.estimatedRowHeight = 140
        self.shipInfoCategoryTableview.rowHeight = UITableViewAutomaticDimension
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        self.shipInfoCategoryTableview.parallaxHeader.view = self.myHeaderView
        self.shipInfoCategoryTableview.parallaxHeader.height = 250
        self.shipInfoCategoryTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.shipInfoCategoryTableview.parallaxHeader.minimumHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let imageUrlStr = self.shipInfoCategoryObject?.imageUrl
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSessionDestinationShipInfoDetails")
        self.backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        self.progressbar.setProgress(0.0, animated: false)
        
        if (self.shipInfoCategoryObject?.attatchFileUrl) != nil && self.shipInfoCategoryObject?.attatchFileUrl?.count != 0
        {
            self.downloadButton.isEnabled = true
            self.downloadButton.tintColor = .white
        }
        else {
            self.downloadButton.isEnabled = false
            self.downloadButton.tintColor = .clear
        }
        
        self.downloadBgview.isHidden = true
        self.downloadContainerView.isHidden = true
        
        self.downloadContainerView.layer.cornerRadius = 3
        self.downloadContainerView.layer.masksToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // self.navigationController?.navigationBar.backItem?.title = ""
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgview.isHidden = true
            self.downloadContainerView.isHidden = true
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reachabilityChanged"), object: nil)
        self.backgroundSession.invalidateAndCancel()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func reachabilityChanged() {
        
        if ReachabilityManager.shared.reachabilityStatus == .notReachable {
            if downloadTask != nil{
                downloadTask.cancel()
                self.downloadBgview.isHidden = true
                self.downloadContainerView.isHidden = true
                self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "shipIngoCategoryDetails", for: indexPath) as! CategoryHeaderTableViewCell
        cell.headerTitleLabel.text = self.shipInfoCategoryObject?.detailsDescription
        cell.selectionStyle = .none
        return cell
        
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
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        let reachibility = Reachability()!
        if reachibility.isReachable {
            if var urlPath = self.shipInfoCategoryObject?.attatchFileUrl {
                if self.downloadBgview.isHidden == true {
                    urlPath = urlPath.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                    let url = URL(string: UrlMCP.server_base_url + urlPath)!
                    downloadTask = backgroundSession.downloadTask(with: url)
                    downloadTask.resume()
                    self.downloadBgview.isHidden = false
                    self.downloadContainerView.isHidden = false
                }
            }
        }
        else {
            self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
        }
    }
    
    
    @IBAction func downloadCancelButtonAction(_ sender: Any) {
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgview.isHidden = true
            self.downloadContainerView.isHidden = true
        }
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
        if let name = self.shipInfoCategoryObject?.attatchFileName {
            fileName = "/" + name
        }
        else {
            fileName = "/file.pdf"
        }
        
        //let name = "/" + self.shopObject?.attatchFileName
        //        if name.range(of:".pdf") == nil {
        //            name = name + ".pdf"
        //        }
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat(fileName))
        self.downloadBgview.isHidden = true
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
        self.progressbar.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        self.progressbar.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
        self.downloadBgview.isHidden = true
        self.downloadContainerView.isHidden = true
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }

    
}
