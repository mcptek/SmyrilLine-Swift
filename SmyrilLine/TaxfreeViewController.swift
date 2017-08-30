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

class TaxfreeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {

    
    @IBOutlet weak var myHeaderView: UIView!
    @IBOutlet weak var taxfreeShopTableView: UITableView!
    @IBOutlet weak var taxFreeShopHeaderImageview: UIImageView!
    @IBOutlet weak var shopOPeningClosingTimeLabel: UILabel!
    @IBOutlet weak var shopLocationLabel: UILabel!
    
    var myCustomView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var shopObject: TaxFreeShopInfo?
    private let KtableHeaderHeight: CGFloat = 300.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.myCustomView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        scrollView = MXScrollView()
        scrollView.parallaxHeader.view = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView // You can set the parallax header view from a nib.
        scrollView.parallaxHeader.height = 150
        scrollView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        scrollView.parallaxHeader.minimumHeight = 20
        self.view.addSubview(scrollView)
        scrollView.addSubview(self.taxfreeShopTableView)
        
//        self.myHeaderView = self.taxfreeShopTableView.tableHeaderView
//        self.taxfreeShopTableView.tableHeaderView = nil
//        self.taxfreeShopTableView.addSubview(self.myHeaderView)
//        self.taxfreeShopTableView.contentInset = UIEdgeInsetsMake(KtableHeaderHeight, 0, 0, 0)
//        self.taxfreeShopTableView.contentOffset = CGPoint(x:0, y:-KtableHeaderHeight)
//        self.updateHeaderView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       // self.CallTaxFreeShopAPI()
    }
    
    func updateHeaderView()  {
        var headerRect = CGRect(x:0,y:-KtableHeaderHeight,width:self.taxfreeShopTableView.bounds.width,height:KtableHeaderHeight)
        if self.taxfreeShopTableView.contentOffset.y < -KtableHeaderHeight
        {
            headerRect.origin.y = self.taxfreeShopTableView.contentOffset.y
            headerRect.size.height = -self.taxfreeShopTableView.contentOffset.y
        }
        self.myHeaderView.frame = headerRect
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taxfreecell") as! TaxFreeTableViewCell
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        //self.updateHeaderView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func CallTaxFreeShopAPI() {
        
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.taxFreeShopParentPath + "/Eng", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<TaxFreeShopInfo>) in
                
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.shopObject = response.result.value
                        if let imageUrlStr = self.shopObject?.shopImageUrlStr
                        {
                            //self.taxFreeShopHeaderImageview.sd_setShowActivityIndicatorView(true)
                            //self.taxFreeShopHeaderImageview.sd_setIndicatorStyle(.gray)
                            //self.myCustomView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
                        }
                        
//                        if let location = self.shopObject?.shopLocation
//                        {
//                            self.shopLocationLabel.text = location
//                        }
//                        
//                        if let time = self.shopObject?.shopOpeningClosingTime
//                        {
//                            self.shopOPeningClosingTimeLabel.text = time
//                        }
                        
                    }
                case .failure:
                    self.showAlert(title: "Error", message: (response.result.error?.localizedDescription)!)
                }
                self.taxfreeShopTableView.reloadData()
                //self.taxfreeShopTableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

}
