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

class DestinationCategoryViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var categoryTableview: UITableView!
    
    var destinationCategoryArray: TaxFreeShopInfo?
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var destinationId:String?
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.CallDestinationCategoryAPI()
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
    
    func CallDestinationCategoryAPI() {
        self.activityIndicatorView.startAnimating()
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + "/Eng/" + self.destinationId!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<TaxFreeShopInfo>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.destinationCategoryArray = response.result.value
                        self.categoryTableview.reloadData()
                       // self.destinaionArray = response.result.value?[0].name
                        //self.destinationTableview.reloadData()
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
        
        return self.destinationCategoryArray?.itemArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationCategoryTableViewCell", for: indexPath) as! DestinationCategoryTableViewCell
//        cell.restaurantNameLabel.text = self.restaurantsArray?[indexPath.section].name
//        if let imageUrlStr = self.restaurantsArray?[indexPath.section].imageUrl
//        {
//            cell.restaurantImageView.sd_setShowActivityIndicatorView(true)
//            cell.restaurantImageView.sd_setIndicatorStyle(.gray)
//            cell.restaurantImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
//            
//        }
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



}
