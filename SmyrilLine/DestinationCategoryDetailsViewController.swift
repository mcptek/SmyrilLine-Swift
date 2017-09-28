//
//  DestinationCategoryDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/28/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import SDWebImage
import MXParallaxHeader

class DestinationCategoryDetailsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var categoryDetailsTableview: UITableView!
    
    var destinationName:String?
    var activityIndicatorView: UIActivityIndicatorView!
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var destinationCategoryDetailsArray: TaxFreeShopInfo?
    var headerCurrentStatus = 2
    var isExpanded = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.destinationName
        
        self.categoryDetailsTableview.estimatedRowHeight = 140
        self.categoryDetailsTableview.rowHeight = UITableViewAutomaticDimension
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        self.categoryDetailsTableview.parallaxHeader.view = self.myHeaderView
        self.categoryDetailsTableview.parallaxHeader.height = 250
        self.categoryDetailsTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.categoryDetailsTableview.parallaxHeader.minimumHeight = 50
        
        if self.destinationCategoryDetailsArray?.itemArray?.isEmpty == false
        {
            for _ in (self.destinationCategoryDetailsArray?.itemArray)!
            {
                self.isExpanded.append(false)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let imageUrlStr = self.destinationCategoryDetailsArray?.shopImageUrlStr
        {
            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
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
        return (self.destinationCategoryDetailsArray?.itemArray?.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryDetailsHeaderCell", for: indexPath) as! CategoryHeaderTableViewCell
            cell.headerTitleLabel.text = self.destinationCategoryDetailsArray?.shopOpeningClosingTime
            let LineLengthOfLabel = self.countLabelLines(label: cell.headerTitleLabel)
            if LineLengthOfLabel <= 2
            {
                cell.seeMoreButton.isHidden = true
            }
            else
            {
                cell.seeMoreButton.isHidden = false
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCategoryDetailsCell", for: indexPath) as! DestinationCategoryDetailsTableViewCell
            if let imageUrlStr = self.destinationCategoryDetailsArray?.itemArray?[indexPath.section - 1].imageUrl
            {
                cell.categoryImageView.sd_setShowActivityIndicatorView(true)
                cell.categoryImageView.sd_setIndicatorStyle(.gray)
                cell.categoryImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
                
            }
            if let categoryname = self.destinationCategoryDetailsArray?.itemArray?[indexPath.section - 1].name
            {
                cell.nameTitleLabel.text = categoryname
            }
            if let headerName = self.destinationCategoryDetailsArray?.itemArray?[indexPath.section - 1].objectHeader
            {
                cell.headerTitleLabel.text = headerName
            }
            
            let LineLengthOfLabel = self.countLabelLines(label: cell.headerTitleLabel)
            if LineLengthOfLabel <= 2
            {
                cell.headerTitleSeeMoreButton.isHidden = true
            }
            else
            {
                cell.headerTitleSeeMoreButton.isHidden = false
                if self.isExpanded[indexPath.section - 1] == false
                {
                    cell.headerTitleLabel.numberOfLines = 2
                    cell.headerTitleSeeMoreButton.setTitle("See More", for: .normal)
                }
                else
                {
                    cell.headerTitleLabel.numberOfLines = 0
                    cell.headerTitleSeeMoreButton.setTitle("See Less", for: .normal)
                }
                cell.headerTitleSeeMoreButton.tag = 1000 + (indexPath.section - 1)
                cell.headerTitleSeeMoreButton.addTarget(self, action: #selector(CategorySeeMoreOrLesssButtonAction(_:)), for: .touchUpInside)
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

    func countLabelLines(label: UILabel) -> Int {
        //  Call self.layoutIfNeeded() //if your view uses auto layout
        if label.text != nil
        {
            let myText = label.text! as NSString
            let rect = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
            let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
            return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
        }
        else
        {
            return 0
        }
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
        self.categoryDetailsTableview.reloadData()
        
    }
    
    func CategorySeeMoreOrLesssButtonAction(_ sender : UIButton)  {
        if self.isExpanded[sender.tag - 1000] == false
        {
            self.isExpanded[sender.tag - 1000] = true
        }
        else
        {
             self.isExpanded[sender.tag - 1000] = false
        }
        self.categoryDetailsTableview.reloadData()
        
    }
}
