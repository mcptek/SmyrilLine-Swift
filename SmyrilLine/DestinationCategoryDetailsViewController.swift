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
    
    var activityIndicatorView: UIActivityIndicatorView!
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var destinationCategoryDetailsObject: GeneralCategory?
    var headerCurrentStatus = 2
    var isExpanded = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.destinationCategoryDetailsObject?.name
        
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
        
        if self.destinationCategoryDetailsObject?.itemArray?.isEmpty == false
        {
            for _ in (self.destinationCategoryDetailsObject?.itemArray)!
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
        if let imageUrlStr = self.destinationCategoryDetailsObject?.imageUrl
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
        return (self.destinationCategoryDetailsObject?.itemArray?.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryDetailsHeaderCell", for: indexPath) as! CategoryHeaderTableViewCell
            cell.headerTitleLabel.text = self.destinationCategoryDetailsObject?.detailsDescription
            if (self.destinationCategoryDetailsObject?.itemArray?.isEmpty)! {
                cell.seeMoreButton.isHidden = true
                cell.seeMoreButtonHeightConstraint.constant = 0
                cell.headerTitleLabel.numberOfLines = 0
            }
            else {
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
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCategoryDetailsCell", for: indexPath) as! DestinationCategoryDetailsTableViewCell
            if let imageUrlStr = self.destinationCategoryDetailsObject?.itemArray?[indexPath.section - 1].imageUrl
            {
                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                cell.categoryImageView.sd_setShowActivityIndicatorView(true)
                cell.categoryImageView.sd_setIndicatorStyle(.gray)
                cell.categoryImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
            }
            else
            {
                cell.categoryImageView.image = nil
            }
            
            if let categoryname = self.destinationCategoryDetailsObject?.itemArray?[indexPath.section - 1].name
            {
                cell.nameTitleLabel.text = categoryname
            }
            else
            {
                cell.nameTitleLabel.text = nil
            }
            
            if let headerName = self.destinationCategoryDetailsObject?.itemArray?[indexPath.section - 1].destinationDescription
            {
                cell.headerTitleLabel.text = headerName
            }
            else
            {
                cell.headerTitleLabel.text = nil
            }
            
            let LineLengthOfLabel = self.countLabelLines(label: cell.headerTitleLabel) - 1
            if LineLengthOfLabel <= 2
            {
                cell.headerTitleSeeMoreButton.isHidden = true
                cell.seeMoreButtonHeightConstraint.constant = 0
            }
            else
            {
                cell.headerTitleSeeMoreButton.isHidden = false
                cell.seeMoreButtonHeightConstraint.constant = 30
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
        return 2.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 2.0
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
        self.categoryDetailsTableview.scrollToNearestSelectedRow(at: .middle, animated: true)
        //let savedIndex = self.categoryDetailsTableview.indexPathsForVisibleRows?.first
        //self.categoryDetailsTableview.scrollToRow(at: savedIndex!, at: .top, animated: false)
        
    }
}
