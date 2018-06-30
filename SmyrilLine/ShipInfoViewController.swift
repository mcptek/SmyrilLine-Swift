//
//  ShipInfoViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/11/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage
import MXParallaxHeader
import ReachabilitySwift

class ShipInfoViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, URLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var shipInfotableView: UITableView!
    @IBOutlet weak var downloadBgview: UIView!
    @IBOutlet weak var downloadContainerview: UIView!
    @IBOutlet weak var progressview: UIProgressView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var cellIndex = 1
    var shipInfoObject: GeneralCategory?
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var shipInfoCategoryId: String?
    var headerCurrentStatus = 0
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        self.navigationItem.title = NSLocalizedString("Ship Info", comment: "")
        self.shipInfotableView.estimatedRowHeight = 140
        self.shipInfotableView.rowHeight = UITableViewAutomaticDimension
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView) 
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        self.shipInfotableView.parallaxHeader.view = self.myHeaderView
        self.shipInfotableView.parallaxHeader.height = 250
        self.shipInfotableView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.shipInfotableView.parallaxHeader.minimumHeight = 50

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.title = "Ship Info"
        self.navigationController?.navigationBar.isHidden = false
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSessionShipinfo")
        self.backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        self.progressview.setProgress(0.0, animated: false)
        
        self.downloadButton.isEnabled = false
        self.downloadButton.tintColor = .clear
        
        self.downloadBgview.isHidden = true
        self.downloadContainerview.isHidden = true
        
        self.downloadContainerview.layer.cornerRadius = 3
        self.downloadContainerview.layer.masksToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgview.isHidden = true
            self.downloadContainerview.isHidden = true
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reachabilityChanged"), object: nil)
        self.backgroundSession.invalidateAndCancel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       // self.navigationController?.navigationBar.backItem?.title = ""
        self.CallShipInfoAPI()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: nil)
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
    
    func reachabilityChanged() {
        
        if ReachabilityManager.shared.reachabilityStatus == .notReachable {
            if downloadTask != nil{
                downloadTask.cancel()
                self.downloadBgview.isHidden = true
                self.downloadContainerview.isHidden = true
                self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
            }
        }
    }
    
    func CallShipInfoDetailsAPI() {
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let shipId = UserDefaults.standard.value(forKey: "CurrentSelectedShipdId") as! String
        var language = "en"
        if UserDefaults.standard.value(forKey: "CurrentSelectedLanguage") != nil {
            let settingsLanguage = UserDefaults.standard.value(forKey: "CurrentSelectedLanguage")  as! Int
            switch settingsLanguage {
            case 0:
                language = "/en/"
            case 1:
                language = "/de/"
            case 2:
                language = "/fo/"
            default:
                language = "/da/"
            }
        }
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.ShipInfoParentPath + language + "\(shipId)/\(self.shipInfoCategoryId!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<GeneralCategory>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextScene = storyBoard.instantiateViewController(withIdentifier: "shipInfoDetails") as! ShipInfoDetailsViewController
                        nextScene.shipInfoCategoryObject = response.result.value
                        self.navigationController?.pushViewController(nextScene, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func CallShipInfoAPI() {
        self.activityIndicatorView.startAnimating()
        let shipId = UserDefaults.standard.value(forKey: "CurrentSelectedShipdId") as! String
        var language = "en"
        if UserDefaults.standard.value(forKey: "CurrentSelectedLanguage") != nil {
            let settingsLanguage = UserDefaults.standard.value(forKey: "CurrentSelectedLanguage")  as! Int
            switch settingsLanguage {
            case 0:
                language = "/en/"
            case 1:
                language = "/de/"
            case 2:
                language = "/fo/"
            default:
                language = "/da/"
            }
        }
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.ShipInfoParentPath + language + "\(shipId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<GeneralCategory>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.shipInfoObject = response.result.value
                        if let imageUrlStr = self.shipInfoObject?.imageUrl
                        {
                            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                            //self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: "http://stage-smy-wp.mcp.com:82/uploads/7b55bfd1-8ea9-4108-969c-959a63241881_MS_Norr%C3%B6na.01.jpg"), placeholderImage: UIImage.init(named: "placeholder"))
                        }
                        if (self.shipInfoObject?.attatchFileUrl) != nil && self.shipInfoObject?.attatchFileUrl?.count != 0
                        {
                            self.downloadButton.isEnabled = true
                            self.downloadButton.tintColor = .white
                        }
                        else {
                            self.downloadButton.isEnabled = false
                            self.downloadButton.tintColor = .clear
                        }
                        
                        self.shipInfotableView.reloadData()
                    }
                case .failure:
                    self.showAlert(title: "Error", message: (response.result.error?.localizedDescription)!)
                }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var totalCount = 1
        if let count = self.shipInfoObject?.itemArray?.count
        {
            totalCount += (count / 2 ) + (count % 2)
        }
        
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryHeaderCelll", for: indexPath) as! CategoryHeaderTableViewCell
            cell.headerTitleLabel.text = self.shipInfoObject?.detailsDescription
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
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCategoryCelll", for: indexPath) as! DestinationCategoryTableViewCell
            self.cellIndex = (indexPath.row - 1) * 2
            if let imageUrlStr = self.shipInfoObject?.itemArray?[self.cellIndex].imageUrl
            {
                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                cell.leftCategoryImageView.sd_setShowActivityIndicatorView(true)
                cell.leftCategoryImageView.sd_setIndicatorStyle(.gray)
                cell.leftCategoryImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                
            }
            if let categoryname = self.shipInfoObject?.itemArray?[self.cellIndex].name
            {
                cell.leftCategoryNameLabel.text = categoryname
            }
            if let categoryId = self.shipInfoObject?.itemArray?[self.cellIndex].childrenId
            {
                cell.leftContainerButton.tag = 1000 + Int(categoryId)!
                cell.leftContainerButton.addTarget(self, action: #selector(shipInfoCategoryDetailsButton(_:)), for: .touchUpInside)
            }
            
            self.cellIndex += 1
            if self.cellIndex < (self.shipInfoObject?.itemArray?.count)!
            {
                if let imageUrlStr = self.shipInfoObject?.itemArray?[self.cellIndex].imageUrl
                {
                    let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                    cell.rightCategotyImageView.sd_setShowActivityIndicatorView(true)
                    cell.rightCategotyImageView.sd_setIndicatorStyle(.gray)
                    cell.rightCategotyImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                    
                }
                if let categoryname = self.shipInfoObject?.itemArray?[self.cellIndex].name
                {
                    cell.rightCategoryNameLabel.text = categoryname
                }
                
                if let categoryId = self.shipInfoObject?.itemArray?[self.cellIndex].childrenId
                {
                    cell.rightContainerButton.tag = 1000 + Int(categoryId)!
                    cell.rightContainerButton.addTarget(self, action: #selector(shipInfoCategoryDetailsButton(_:)), for: .touchUpInside)
                }
            }
            else
            {
                cell.rightCategotyImageView.image = nil
                cell.rightCategoryNameLabel.text = ""
                cell.rightContainerView.isHidden = true
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
    
    func shipInfoCategoryDetailsButton(_ sender : UIButton)  {
        self.shipInfoCategoryId = String(sender.tag - 1000)
        self.CallShipInfoDetailsAPI()
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
        self.shipInfotableView.reloadData()
        
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        let reachibility = Reachability()!
        if reachibility.isReachable {
            if var urlPath = self.shipInfoObject?.attatchFileUrl {
                if self.downloadBgview.isHidden == true {
                    urlPath = urlPath.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                    if let url = URL(string: UrlMCP.server_base_url + urlPath) {
                        downloadTask = backgroundSession.downloadTask(with: url)
                        downloadTask.resume()
                        self.downloadBgview.isHidden = false
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
    
    @IBAction func downloadCancelbuttonAction(_ sender: Any) {
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgview.isHidden = true
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
        if let name = self.shipInfoObject?.attatchFileName {
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
        self.progressview.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        self.progressview.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
        self.downloadBgview.isHidden = true
        self.downloadContainerview.isHidden = true
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }

    
}
