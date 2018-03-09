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

class ShipInfoViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var shipInfotableView: UITableView!
    
    var cellIndex = 1
    var shipInfoObject: TaxFreeShopInfo?
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var shipInfoCategoryId: String?
    
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        self.title = "Ship Info"
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
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
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.attachToScrollView(self.shipInfotableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       // self.navigationController?.navigationBar.backItem?.title = ""
        self.CallShipInfoAPI()
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
            .responseObject { (response: DataResponse<TaxFreeShopInfo>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextScene = storyBoard.instantiateViewController(withIdentifier: "shipInfoDetails") as! ShipInfoDetailsViewController
                        nextScene.shipInfoCategoryDetailsArray = response.result.value
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
            .responseObject { (response: DataResponse<TaxFreeShopInfo>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.shipInfoObject = response.result.value
                        if let imageUrlStr = self.shipInfoObject?.shopImageUrlStr
                        {
                            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
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
            cell.headerTitleLabel.text = self.shipInfoObject?.shopOpeningClosingTime
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
            if let categoryId = self.shipInfoObject?.itemArray?[self.cellIndex].objectId
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
                
                if let categoryId = self.shipInfoObject?.itemArray?[self.cellIndex].objectId
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
    
    

}
