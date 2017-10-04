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

class TaxfreeDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var productDetailsTableview: UITableView!
    
    var productDetailsObject: ShopObject?
    var myHeaderView: TaxfreeHeaderDetailsHeader!
    var scrollView: MXScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        self.title = "Tax free"
        
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeHeaderDetailsHeader", owner: self, options: nil)?.first as? UIView as! TaxfreeHeaderDetailsHeader
        self.productDetailsTableview.parallaxHeader.view = self.myHeaderView
        self.productDetailsTableview.parallaxHeader.height = 250
        self.productDetailsTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.productDetailsTableview.parallaxHeader.minimumHeight = 50
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let imageUrlStr = self.productDetailsObject?.imageUrl
        {
            self.myHeaderView.productImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.productImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.productImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
        }
        
        if let productName = self.productDetailsObject?.name
        {
            self.myHeaderView.productNameLabel.text = productName
        }
        
        if let price = self.productDetailsObject?.objectPrice
        {
            self.myHeaderView.productPriceLabel.text = price
        }
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productDetailsCell", for: indexPath) as! TaxfreeProductDetailsTableViewCell
        if let productDetails = self.productDetailsObject?.objectHeader
        {
            cell.productDetailsLabel.text = productDetails
        }
        else
        {
            cell.productDetailsLabel.text = nil
        }
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
