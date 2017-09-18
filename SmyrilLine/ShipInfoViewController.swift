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
    
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        let navigationBar = navigationController!.navigationBar
        navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
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
        self.title = "Ship Info"
        self.navigationController?.navigationBar.isHidden = false
        let navigationBar = navigationController!.navigationBar
        navigationBar.attachToScrollView(self.shipInfotableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationBar = navigationController!.navigationBar
        navigationBar.reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.navigationBar.backItem?.title = ""
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
    
    
    
//    func Acknodledge()  {
////        http://stage-smy-wp.mcp.com:82/api/Schedule/AckQueuedBulletin?scheduleId=66,67&clientId=31E9A95C-DA3A-43B2-B009-4C2DEE6B7433
//        let bulletinAcknowledgementUrl = String(format: "/api/Schedule/AckQueuedBulletin?scheduleId=%@&clientId=%@", messageId, clientId!)
//       // print(UrlMCP.server_base_url + bulletinAcknowledgementUrl)
//        Alamofire.request(UrlMCP.server_base_url + bulletinAcknowledgementUrl, method:.get, parameters: params, encoding: URLEncoding.httpBody, headers: nil)
//            .responseJSON { (response) in
//                switch response.result {
//                case .success:
//                    print("success")
//                    completionHandler(.newData)
//                case .failure(_):
//                    print(response.result.error?.localizedDescription ?? "Default warning!!")
//                    completionHandler(.newData)
//                }
//        }
//    }
    
    func CallShipInfoAPI() {
        self.activityIndicatorView.startAnimating()
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.ShipInfoParentPath + "/Eng", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
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
                            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
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
                cell.leftCategoryImageView.sd_setShowActivityIndicatorView(true)
                cell.leftCategoryImageView.sd_setIndicatorStyle(.gray)
                cell.leftCategoryImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
                
            }
            if let categoryname = self.shipInfoObject?.itemArray?[self.cellIndex].name
            {
                cell.leftCategoryNameLabel.text = categoryname
            }
            self.cellIndex += 1
            if self.cellIndex < (self.shipInfoObject?.itemArray?.count)!
            {
                if let imageUrlStr = self.shipInfoObject?.itemArray?[self.cellIndex].imageUrl
                {
                    cell.rightCategotyImageView.sd_setShowActivityIndicatorView(true)
                    cell.rightCategotyImageView.sd_setIndicatorStyle(.gray)
                    cell.rightCategotyImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
                    
                }
                if let categoryname = self.shipInfoObject?.itemArray?[self.cellIndex].name
                {
                    cell.rightCategoryNameLabel.text = categoryname
                }
            }
            else
            {
                cell.rightCategotyImageView.image = nil
                cell.rightCategoryNameLabel.text = ""
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
    

}
