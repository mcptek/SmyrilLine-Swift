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

class ShipInfoDetailsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    var shipInfoCategoryDetailsArray: TaxFreeShopInfo?
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    
    @IBOutlet weak var shipInfoCategoryTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = self.shipInfoCategoryDetailsArray?.shopName
        
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
        if let imageUrlStr = self.shipInfoCategoryDetailsArray?.shopImageUrlStr
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "shipIngoCategoryDetails", for: indexPath) as! CategoryHeaderTableViewCell
        cell.headerTitleLabel.text = self.shipInfoCategoryDetailsArray?.shopOpeningClosingTime
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
