//
//  DestinationCategoryViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/31/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage
import MXParallaxHeader
import ReachabilitySwift

class DestinationCategoryViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, URLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate  {

    @IBOutlet weak var categoryTableview: UITableView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var downloadBgView: UIView!
    @IBOutlet weak var downloadContainerview: UIView!
    @IBOutlet weak var progressbar: UIProgressView!
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var cellIndex = 1
    var destinationCategoryObject: GeneralCategory?
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var destinationId:String?
    var destinationName:String?
    var destinationCategoryId: String?
    var headerCurrentStatus = 0
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.title = self.destinationName
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        self.categoryTableview.estimatedRowHeight = 140
        self.categoryTableview.rowHeight = UITableViewAutomaticDimension
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        self.categoryTableview.parallaxHeader.view = self.myHeaderView
        self.categoryTableview.parallaxHeader.height = 250
        self.categoryTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.categoryTableview.parallaxHeader.minimumHeight = 50

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSessionDestinationCategory")
        self.backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        self.progressbar.setProgress(0.0, animated: false)
        
        self.downloadButton.isEnabled = false
        self.downloadButton.tintColor = .clear
        
        self.downloadBgView.isHidden = true
        self.downloadContainerview.isHidden = true
        
        self.downloadContainerview.layer.cornerRadius = 3
        self.downloadContainerview.layer.masksToBounds = true
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        self.navigationController?.navigationBar.backItem?.title = ""
        self.CallDestinationCategoryAPI()
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
                self.downloadBgView.isHidden = true
                self.downloadContainerview.isHidden = true
                self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
            }
        }
    }
    
    func CallDestinationCategoryDetailsAPI() {
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
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + language + "\(shipId)/\(self.destinationCategoryId!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<GeneralCategory>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextScene = storyBoard.instantiateViewController(withIdentifier: "destinationCategoryDetails") as! DestinationCategoryDetailsViewController
                        nextScene.destinationCategoryDetailsObject = response.result.value
                        self.navigationController?.pushViewController(nextScene, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func CallDestinationCategoryAPI() {
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
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + language + "\(shipId)/\(self.destinationId!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<GeneralCategory>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.destinationCategoryObject = response.result.value
                        if let imageUrlStr = self.destinationCategoryObject?.imageUrl
                        {
                            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                        }
                        if (self.destinationCategoryObject?.attatchFileUrl) != nil && self.destinationCategoryObject?.attatchFileUrl?.count != 0
                        {
                            self.downloadButton.isEnabled = true
                            self.downloadButton.tintColor = .white
                        }
                        else {
                            self.downloadButton.isEnabled = false
                            self.downloadButton.tintColor = .clear
                        }
                        self.categoryTableview.reloadData()
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var totalCount = 1
        if let count = self.destinationCategoryObject?.itemArray?.count
        {
            totalCount += (count / 2 ) + (count % 2)
        }
        
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryHeaderCell", for: indexPath) as! CategoryHeaderTableViewCell
            cell.headerTitleLabel.text = self.destinationCategoryObject?.detailsDescription
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCategoryCell", for: indexPath) as! DestinationCategoryTableViewCell
            self.cellIndex = (indexPath.row - 1) * 2
            if let imageUrlStr = self.destinationCategoryObject?.itemArray?[self.cellIndex].imageUrl
            {
                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                cell.leftCategoryImageView.sd_setShowActivityIndicatorView(true)
                cell.leftCategoryImageView.sd_setIndicatorStyle(.gray)
                cell.leftCategoryImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                
            }
            if let categoryname = self.destinationCategoryObject?.itemArray?[self.cellIndex].name
            {
                cell.leftCategoryNameLabel.text = categoryname
            }
            if let categoryId = self.destinationCategoryObject?.itemArray?[self.cellIndex].childrenId
            {
                cell.leftContainerButton.tag = 1000 + Int(categoryId)!
                cell.leftContainerButton.addTarget(self, action: #selector(categoryDetailsButton(_:)), for: .touchUpInside)
            }
            self.cellIndex += 1
            if self.cellIndex < (self.destinationCategoryObject?.itemArray?.count)!
            {
                if let imageUrlStr = self.destinationCategoryObject?.itemArray?[self.cellIndex].imageUrl
                {
                    let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                    cell.rightContainerView.isHidden = false
                    cell.rightCategotyImageView.sd_setShowActivityIndicatorView(true)
                    cell.rightCategotyImageView.sd_setIndicatorStyle(.gray)
                    cell.rightCategotyImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                    
                }
                if let categoryname = self.destinationCategoryObject?.itemArray?[self.cellIndex].name
                {
                    cell.rightCategoryNameLabel.text = categoryname
                }
                if let categoryId = self.destinationCategoryObject?.itemArray?[self.cellIndex].childrenId
                {
                    cell.rightContainerButton.tag = 1000 + Int(categoryId)!
                    cell.rightContainerButton.addTarget(self, action: #selector(categoryDetailsButton(_:)), for: .touchUpInside)
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
        return 3.5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 3.5
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
    
    func categoryDetailsButton(_ sender : UIButton)  {
        self.destinationCategoryId = String(sender.tag - 1000)
        self.CallDestinationCategoryDetailsAPI()
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
        self.categoryTableview.reloadData()
        
    }
    
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        let reachibility = Reachability()!
        if reachibility.isReachable {
            if var urlPath = self.destinationCategoryObject?.attatchFileUrl {
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
    
    
    @IBAction func downloadCancelButtonAtion(_ sender: Any) {
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
        if let name = self.destinationCategoryObject?.attatchFileName {
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
