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
    
    var productName: String?
    var productPrice: String?
    var productDetails: String?
    var productImageUrl: String?
    var myHeaderView: TaxfreeHeaderDetailsHeader!
    var scrollView: MXScrollView!
    var headerCurrentStatus = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        self.title = "Price and Menu"
        
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeHeaderDetailsHeader", owner: self, options: nil)?.first as? UIView as! TaxfreeHeaderDetailsHeader
        self.productDetailsTableview.parallaxHeader.view = self.myHeaderView
        self.productDetailsTableview.parallaxHeader.height = 250
        self.productDetailsTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.productDetailsTableview.parallaxHeader.minimumHeight = 50
        
        //self.productDetailsTableview.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.productDetailsTableview.tableFooterView = UIView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let imageUrlStr = self.productImageUrl
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            self.myHeaderView.productImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.productImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.productImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        if let productName = self.productName
        {
            self.myHeaderView.productNameLabel.text = productName
        }
        
        self.productPrice = self.productPrice?.replacingOccurrences(of: "€", with: "", options: .literal, range: nil)
        if let priceObject = self.productPrice
        {
            var price = priceObject.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
            price = "€" + price
            if price.characters.contains(",") {
                let splittedStringsArray = price.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
                if let firstString = splittedStringsArray.first, let secondString = splittedStringsArray.last
                {
                    let numericPart = String(describing: firstString)
                    let fractionPart = String(describing: secondString)
                    let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                    let scriptFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
                    let stringwithSquare = numericPart.attributedStringWithSuperscript(fractionPart, mainStringFont: mainFont, subStringFont: scriptFont, offSetFromBaseLine: 10)
                    self.myHeaderView.productPriceLabel.attributedText = stringwithSquare
                }
                else
                {
                    let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                    self.myHeaderView.productPriceLabel.text = price
                    self.myHeaderView.productPriceLabel.font = mainFont
                    
                }
            }
            else {
                let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                self.myHeaderView.productPriceLabel.text = price
                self.myHeaderView.productPriceLabel.font = mainFont
            }
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productDetailsCell", for: indexPath) as! TaxfreeProductDetailsTableViewCell
            if let productDetails = self.productDetails
            {
                cell.productDetailsLabel.text = productDetails
            }
            else
            {
                cell.productDetailsLabel.text = nil
            }
            
            let LineLengthOfLabel = self.countLabelLines(label: cell.productDetailsLabel) - 1
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
                    cell.productDetailsLabel.numberOfLines = 0
                    cell.seeMoreButton.setTitle("See More", for: .normal)
                }
                else
                {
                    cell.productDetailsLabel.numberOfLines = 2
                    cell.seeMoreButton.setTitle("See More", for: .normal)
                }
                cell.seeMoreButton.addTarget(self, action: #selector(headerSeeMoreOrLesssButtonAction(_:)), for: .touchUpInside)
            }
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeOrderCell", for: indexPath) as! PlaceOrderTableViewCell
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
    
    func headerSeeMoreOrLesssButtonAction(_ sender : UIButton)  {
        self.headerCurrentStatus = 2
        self.productDetailsTableview.reloadData()
        
    }


}
