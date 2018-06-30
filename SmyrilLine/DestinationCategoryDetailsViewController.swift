//
//  DestinationCategoryDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/28/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import SDWebImage
import MXParallaxHeader
import ReachabilitySwift

class DestinationCategoryDetailsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, URLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var categoryDetailsTableview: UITableView!
    
    var activityIndicatorView: UIActivityIndicatorView!
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var destinationCategoryDetailsObject: GeneralCategory?
    var headerCurrentStatus = 2
    var isExpanded = [Bool]()
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var downloadBgView: UIView!
    @IBOutlet weak var downloadContainerview: UIView!
    @IBOutlet weak var progressbar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.destinationCategoryDetailsObject?.name
        
        self.categoryDetailsTableview.estimatedRowHeight = 140
        self.categoryDetailsTableview.rowHeight = UITableViewAutomaticDimension
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        self.categoryDetailsTableview.parallaxHeader.view = self.myHeaderView
        self.categoryDetailsTableview.parallaxHeader.height = 250
        self.categoryDetailsTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.categoryDetailsTableview.parallaxHeader.minimumHeight = 50
        
        if self.destinationCategoryDetailsObject?.itemArray?.isEmpty == false
        {
            for _ in (self.destinationCategoryDetailsObject?.itemArray)!
            {
                self.isExpanded.append(false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let imageUrlStr = self.destinationCategoryDetailsObject?.imageUrl
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSessionDestinationCategoryDetails")
        self.backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        self.progressbar.setProgress(0.0, animated: false)
        
        if (self.destinationCategoryDetailsObject?.attatchFileUrl) != nil && self.destinationCategoryDetailsObject?.attatchFileUrl?.count != 0
        {
            self.downloadButton.isEnabled = true
            self.downloadButton.tintColor = .white
        }
        else {
            self.downloadButton.isEnabled = false
            self.downloadButton.tintColor = .clear
        }
        
        self.downloadBgView.isHidden = true
        self.downloadContainerview.isHidden = true
        
        self.downloadContainerview.layer.cornerRadius = 3
        self.downloadContainerview.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgView.isHidden = true
            self.downloadContainerview.isHidden = true
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
                self.downloadBgView.isHidden = true
                self.downloadContainerview.isHidden = true
                self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.destinationCategoryDetailsObject?.itemArray?.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryDetailsHeaderCell", for: indexPath) as! CategoryHeaderTableViewCell
            cell.headerTitleLabel.text = self.destinationCategoryDetailsObject?.detailsDescription
            if (self.destinationCategoryDetailsObject?.itemArray?.isEmpty)! {
                cell.seeMoreButton.isHidden = true
                cell.seeMoreButtonHeightConstraint.constant = 0
                cell.headerTitleLabel.numberOfLines = 0
            }
            else {
                let LineLengthOfLabel = self.countLabelLines(label: cell.headerTitleLabel) - 1
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
                        cell.headerTitleLabel.numberOfLines = 0
                        cell.seeMoreButton.setTitle("See Less", for: .normal)
                    }
                    else
                    {
                        cell.headerTitleLabel.numberOfLines = 2
                        cell.seeMoreButton.setTitle("See More", for: .normal)
                    }
                    cell.seeMoreButton.addTarget(self, action: #selector(headerSeeMoreOrLesssButtonAction(_:)), for: .touchUpInside)
                }
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCategoryDetailsCell", for: indexPath) as! DestinationCategoryDetailsTableViewCell
            if let imageUrlStr = self.destinationCategoryDetailsObject?.itemArray?[indexPath.section - 1].imageUrl
            {
                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                cell.categoryImageView.sd_setShowActivityIndicatorView(true)
                cell.categoryImageView.sd_setIndicatorStyle(.gray)
                cell.categoryImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
            }
            else
            {
                cell.categoryImageView.image = nil
            }
            
            if let categoryname = self.destinationCategoryDetailsObject?.itemArray?[indexPath.section - 1].name
            {
                cell.nameTitleLabel.text = categoryname
            }
            else
            {
                cell.nameTitleLabel.text = nil
            }
            
            if let headerName = self.destinationCategoryDetailsObject?.itemArray?[indexPath.section - 1].destinationDescription
            {
                cell.headerTitleLabel.text = headerName
            }
            else
            {
                cell.headerTitleLabel.text = nil
            }
            
            let LineLengthOfLabel = self.countLabelLines(label: cell.headerTitleLabel) - 1
            if LineLengthOfLabel <= 2
            {
                cell.headerTitleSeeMoreButton.isHidden = true
                cell.seeMoreButtonHeightConstraint.constant = 0
            }
            else
            {
                cell.headerTitleSeeMoreButton.isHidden = false
                cell.seeMoreButtonHeightConstraint.constant = 30
                if self.isExpanded[indexPath.section - 1] == false
                {
                    cell.headerTitleLabel.numberOfLines = 2
                    cell.headerTitleSeeMoreButton.setTitle("See More", for: .normal)
                }
                else
                {
                    cell.headerTitleLabel.numberOfLines = 0
                    cell.headerTitleSeeMoreButton.setTitle("See Less", for: .normal)
                }
                cell.headerTitleSeeMoreButton.tag = 1000 + (indexPath.section - 1)
                cell.headerTitleSeeMoreButton.addTarget(self, action: #selector(CategorySeeMoreOrLesssButtonAction(_:)), for: .touchUpInside)
            }
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 2.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 2.0
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
        if self.headerCurrentStatus == 2
        {
            self.headerCurrentStatus = 0
        }
        else
        {
            self.headerCurrentStatus = 2
        }
        self.categoryDetailsTableview.reloadData()
        
    }
    
    func CategorySeeMoreOrLesssButtonAction(_ sender : UIButton)  {
        if self.isExpanded[sender.tag - 1000] == false
        {
            self.isExpanded[sender.tag - 1000] = true
        }
        else
        {
             self.isExpanded[sender.tag - 1000] = false
        }
        self.categoryDetailsTableview.reloadData()
        self.categoryDetailsTableview.scrollToNearestSelectedRow(at: .middle, animated: true)
        //let savedIndex = self.categoryDetailsTableview.indexPathsForVisibleRows?.first
        //self.categoryDetailsTableview.scrollToRow(at: savedIndex!, at: .top, animated: false)
        
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        let reachibility = Reachability()!
        if reachibility.isReachable {
            if var urlPath = self.destinationCategoryDetailsObject?.attatchFileUrl {
                if self.downloadBgView.isHidden == true {
                    urlPath = urlPath.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                    if let url = URL(string: UrlMCP.server_base_url + urlPath) {
                        downloadTask = backgroundSession.downloadTask(with: url)
                        downloadTask.resume()
                        self.downloadBgView.isHidden = false
                        self.downloadContainerview.isHidden = false
                    }
                    else {
                        self.showDownloadFailAlert()
                    }
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
            self.downloadBgView.isHidden = true
            self.downloadContainerview.isHidden = true
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
        if let name = self.destinationCategoryDetailsObject?.attatchFileName {
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
        self.downloadBgView.isHidden = true
        self.downloadContainerview.isHidden = true
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
        self.downloadBgView.isHidden = true
        self.downloadContainerview.isHidden = true
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    
}
