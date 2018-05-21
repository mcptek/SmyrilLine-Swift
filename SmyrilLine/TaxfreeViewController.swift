//
//  TaxfreeViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/25/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage
import MXParallaxHeader
import ReachabilitySwift

class TaxfreeViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, URLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var myTaxfreeCollectionView: UICollectionView!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var downloadBgView: UIView!
    @IBOutlet weak var downloadProgressContainerView: UIView!
    @IBOutlet weak var taxfreeTableview: UITableView!
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var myHeaderView: TaxfreeHeader!
    var scrollView: MXScrollView!
    var productInfoCategoryId: String?
    var activityIndicatorView: UIActivityIndicatorView!
    var shopObject: TaxFreeShopInfo?
    var headerCurrentStatus = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeHeader", owner: self, options: nil)?.first as? UIView as! TaxfreeHeader
        self.taxfreeTableview.parallaxHeader.view = self.myHeaderView
        self.taxfreeTableview.parallaxHeader.height = 250
        self.taxfreeTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.taxfreeTableview.parallaxHeader.minimumHeight = 50
        
        //self.myTaxfreeCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.taxfreeTableview.tableFooterView = UIView()
        self.loadShopDetails()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        self.downloadProgressView.setProgress(0.0, animated: false)
        
        self.downloadButton.isEnabled = false
        self.downloadButton.tintColor = .clear
        
        self.downloadBgView.isHidden = true
        self.downloadProgressContainerView.isHidden = true
        
        self.downloadProgressContainerView.layer.cornerRadius = 3
        self.downloadProgressContainerView.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.shopObject?.itemArray = nil
        //self.CallTaxfreeShopAPI()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name(rawValue: "ReachililityChangeStatus"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgView.isHidden = true
            self.downloadProgressContainerView.isHidden = true
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reachabilityChanged"), object: nil)
        backgroundSession.invalidateAndCancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadShopDetails()  {
        if let imageUrlStr = self.shopObject?.shopImageUrlStr
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            self.myHeaderView.headerImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.headerImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.headerImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        if let time = self.shopObject?.shopOpeningClosingTime
        {
            self.myHeaderView.headerTimeLabel.text = time
        }
        
        if let location = self.shopObject?.shopLocation
        {
            self.myHeaderView.headerLocationLabel.text = location
        }
        
        if (self.shopObject?.attatchFileUrl) != nil && self.shopObject?.attatchFileUrl?.count != 0
        {
            self.downloadButton.isEnabled = true
            self.downloadButton.tintColor = .white
        }
        else {
            self.downloadButton.isEnabled = false
            self.downloadButton.tintColor = .clear
        }
    }
    
    func reachabilityChanged() {
        
        if ReachabilityManager.shared.reachabilityStatus == .notReachable {
            if downloadTask != nil{
                downloadTask.cancel()
                self.downloadBgView.isHidden = true
                self.downloadProgressContainerView.isHidden = true
                self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = self.shopObject?.itemArray?.count {
            if count == 0 {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No data available"
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            else {
                tableView.separatorStyle = .singleLine
                tableView.backgroundView = nil
            }
        }
        else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Tax free item available"
            noDataLabel.textColor     = UIColor.darkGray
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.shopObject?.itemArray?.count {
            if count == 0 {
                return 0
            }
            else {
                return 2
            }
        }
        else {
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "taxfreeDetailsCell", for: indexPath) as! TaxfreeHeaderTableViewCell
            cell.shopDescriptionLabel.text = self.shopObject?.shopDescription
            let LineLengthOfLabel = self.countLabelLines(label: cell.shopDescriptionLabel) - 1
            if LineLengthOfLabel <= 2
            {
                cell.seeMoreButton.isHidden = true
                cell.seeMoreButtonHeight.constant = 0
            }
            else
            {
                cell.seeMoreButton.isHidden = false
                cell.seeMoreButtonHeight.constant = 30
                if self.headerCurrentStatus == 2
                {
                    cell.shopDescriptionLabel.numberOfLines = 0
                    cell.seeMoreButton.setTitle("See Less", for: .normal)
                }
                else
                {
                    cell.shopDescriptionLabel.numberOfLines = 2
                    cell.seeMoreButton.setTitle("See More", for: .normal)
                }
                cell.seeMoreButton.addTarget(self, action: #selector(headerSeeMoreOrLesssButtonAction(_:)), for: .touchUpInside)
                
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "taxFreeItemCell", for: indexPath) as! TaxfreeItemsTableViewCell
            cell.TaxfreeItemCollectionview.reloadData()
            //cell.TaxfreeItemCollectionview.setNeedsLayout()
            cell.collectionviewHeight.constant = cell.TaxfreeItemCollectionview.collectionViewLayout.collectionViewContentSize.height
            cell.TaxfreeItemCollectionview.setNeedsLayout()
            cell.TaxfreeItemCollectionview.reloadData()
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
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
//        if let count = self.shopObject?.itemArray?.count {
//            if count == 0 {
//                self.myTaxfreeCollectionView.setEmptyMessage("No Tax Free item is available")
//            }
//            else {
//                self.myTaxfreeCollectionView.restore()
//            }
//        }
//        else {
//            self.myTaxfreeCollectionView.setEmptyMessage("No Tax Free item is available")
//        }
        return self.shopObject?.itemArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taxfreeCell", for: indexPath) as! TaxfreeCollectionViewCell
        if let productName = self.shopObject?.itemArray?[indexPath.row].name
        {
            cell.productNameLabel.text = productName
        }
        else
        {
            cell.productNameLabel.text = nil
        }
        
        if let productHeader = self.shopObject?.itemArray?[indexPath.row].shopTitle
        {
            cell.productHeaderLabel.text = productHeader
        }
        else
        {
            cell.productHeaderLabel.text = nil
        }
        
        if let priceObject = self.shopObject?.itemArray?[indexPath.row].objectPrice
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
        else
        {
            cell.productPriceLabel.text = nil
        }
        
        if let imageUrlStr = self.shopObject?.itemArray?[indexPath.row].imageUrl
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            cell.productImageView.sd_setShowActivityIndicatorView(true)
            cell.productImageView.sd_setIndicatorStyle(.gray)
            cell.productImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let objectId = self.shopObject?.itemArray?[indexPath.row].objectId
        {
            self.CallTaxfreeShopDetailsAPIwithObjectId(objectId: objectId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let screenHeight = UIScreen.main.bounds.size.height
        switch screenHeight {
        case 480:
            return CGSize(width: 140, height: 219)
        case 568:
            return CGSize(width: 140, height: 219)
        case 667:
            return CGSize(width: 166.0, height: 219.0)
        case 736:
            return CGSize(width: 186.0, height: 225.0)
        case 1334:
            return CGSize(width: 166.0, height: 219.0)
        case 2208:
            //printf("iPhone 6+/6S+/7+/8+");
            return CGSize(width: 186.0, height: 225.0)
        case 2436:
           // printf("iPhone X");
            return CGSize(width: 186.0, height: 225.0)
        default:
            return CGSize(width: 166.0, height: 219.0)
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

    func headerSeeMoreOrLesssButtonAction(_ sender : UIButton)  {
        if self.headerCurrentStatus == 2
        {
            self.headerCurrentStatus = 0
        }
        else
        {
            self.headerCurrentStatus = 2
        }
        self.taxfreeTableview.reloadData()
        
    }
    
    @IBAction func downloadCancelButtonAction(_ sender: Any) {
        if downloadTask != nil{
            downloadTask.cancel()
            self.downloadBgView.isHidden = true
            self.downloadProgressContainerView.isHidden = true
        }
    }
    
    @IBAction func CatalogueDownLoadButtonAction(_ sender: Any) {
        let reachibility = Reachability()!
        if reachibility.isReachable {
            if var urlPath = self.shopObject?.attatchFileUrl {
                if self.downloadBgView.isHidden == true {
                    urlPath = urlPath.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                    let url = URL(string: UrlMCP.server_base_url + urlPath)!
                    downloadTask = backgroundSession.downloadTask(with: url)
                    downloadTask.resume()
                    self.downloadBgView.isHidden = false
                    self.downloadProgressContainerView.isHidden = false
                }
            }
        }
        else {
            self.showAlert(title: "Error", message: "There is no internet connection now. Please try again later")
        }
    }
    
    
    func CallTaxfreeShopDetailsAPIwithObjectId(objectId: String) {
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

        Alamofire.request(UrlMCP.server_base_url + UrlMCP.taxFreeShopParentPath + language  + "\(String(describing: shipId))/\(objectId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[ShopObject]>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextScene = storyBoard.instantiateViewController(withIdentifier: "taxfreeShopDetails") as! TaxfreeDetailsViewController
                        nextScene.productName = response.result.value?[0].name
                        nextScene.productPrice = response.result.value?[0].objectPrice
                        nextScene.productImageUrl = response.result.value?[0].imageUrl
                        nextScene.productDetails = response.result.value?[0].objectHeader
                        nextScene.productattatchFileUrlPath = response.result.value?[0].attatchFileUrl
                        nextScene.productAttatchFilName = response.result.value?[0].attatchFileName
                        self.navigationController?.pushViewController(nextScene, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }

    func CallTaxfreeShopAPI() {
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
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.taxFreeShopParentPath + language + "\(String(describing: shipId))", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[TaxFreeShopInfo]>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        if response.result.value?.isEmpty == false {
                            self.shopObject = response.result.value?[0]
                            if let imageUrlStr = self.shopObject?.shopImageUrlStr
                            {
                                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                                self.myHeaderView.headerImageView.sd_setShowActivityIndicatorView(true)
                                self.myHeaderView.headerImageView.sd_setIndicatorStyle(.gray)
                                self.myHeaderView.headerImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                            }
                            
                            if let time = self.shopObject?.shopOpeningClosingTime
                            {
                                self.myHeaderView.headerTimeLabel.text = time
                            }
                            
                            if let location = self.shopObject?.shopLocation
                            {
                                self.myHeaderView.headerLocationLabel.text = location
                            }
                            
                            if (self.shopObject?.attatchFileUrl) != nil && self.shopObject?.attatchFileUrl?.count != 0
                            {
                                self.downloadButton.isEnabled = true
                                self.downloadButton.tintColor = .white
                            }
                            else {
                                self.downloadButton.isEnabled = false
                                self.downloadButton.tintColor = .clear
                            }
                        }
                        else {
                            self.myHeaderView.headerImageView.image = nil
                            self.myHeaderView.headerTimeLabel.text = nil
                            self.myHeaderView.headerLocationLabel.text = nil
                            self.shopObject?.itemArray = nil
                        }
                        self.taxfreeTableview.reloadData()
                    }
                case .failure:
                    self.showAlert(title: "Error", message: (response.result.error?.localizedDescription)!)
                }
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
        if let name = self.shopObject?.attatchFileName {
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
        self.downloadProgressContainerView.isHidden = true
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
        self.downloadProgressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        self.downloadProgressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
        self.downloadBgView.isHidden = true
        self.downloadProgressContainerView.isHidden = true
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }

}
