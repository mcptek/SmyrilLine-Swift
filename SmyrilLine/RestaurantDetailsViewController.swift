//
//  RestaurantDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/1/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import SDWebImage
import MXParallaxHeader

class RestaurantDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var restaurantDetailasTableview: UITableView!
    var restaurantDetailsObject: RestaurantDetailsInfo?
    var expandCollapseArray = [true,true,true,false,false,false]
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var currentLyAdultMealSelected = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        self.title = self.restaurantDetailsObject?.name
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        self.restaurantDetailasTableview.parallaxHeader.view = self.myHeaderView
        self.restaurantDetailasTableview.parallaxHeader.height = 250
        self.restaurantDetailasTableview.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.restaurantDetailasTableview.parallaxHeader.minimumHeight = 50
        if let imageUrlStr = self.restaurantDetailsObject?.imageUrl
        {
            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
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
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if currentLyAdultMealSelected {
                if self.restaurantDetailsObject?.adultMeals?.isEmpty == false {
                    return (self.restaurantDetailsObject?.adultMeals?.count)! + 1
                }
                return 1
            }
            else {
                if self.restaurantDetailsObject?.childrenMeals?.isEmpty == false {
                    return (self.restaurantDetailsObject?.childrenMeals?.count)! + 1
                }
                return 1
            }
        case 3:
            if self.restaurantDetailsObject?.breakfastItems?.isEmpty == false {
                return (self.restaurantDetailsObject?.breakfastItems?.count)! + 1
            }
            return 1
        case 4:
            if self.restaurantDetailsObject?.lunchItems?.isEmpty == false {
                return (self.restaurantDetailsObject?.lunchItems?.count)! + 1
            }
            return 1
        default:
            if self.restaurantDetailsObject?.dinnerItems?.isEmpty == false {
                return (self.restaurantDetailsObject?.dinnerItems?.count)! + 1
            }
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantOpenCloseTimeCell", for: indexPath) as! RestaurantOpenCloseTimeTableViewCell
            if let breakfastTime = self.restaurantDetailsObject?.breakfastTime {
                cell.breakfastTimeLabel.text = breakfastTime
            }
            if let lunchTime = self.restaurantDetailsObject?.breakfastTime {
                cell.lunchTimeLabel.text = lunchTime
            }
            if let DinnerTime = self.restaurantDetailsObject?.breakfastTime {
                cell.dinnerTimeLabel.text = DinnerTime
            }
            if self.expandCollapseArray[indexPath.section] {
                cell.expandCollapseImageView.image = UIImage(named: "CollapseArrow")
            }
            else {
                cell.expandCollapseImageView.image = UIImage(named: "ExpandArrow")
            }
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantDetailsInfoCell", for: indexPath) as! RestaurantDetailsInfoTableViewCell
            if let detailsInfo = self.restaurantDetailsObject?.restaurantDescription {
                cell.detailsInfoLabel.text = detailsInfo
            }
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "demoCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section {
        case 0:
            if self.expandCollapseArray[indexPath.section] {
                self.expandCollapseArray[indexPath.section] = false
            }
            else {
                self.expandCollapseArray[indexPath.section] = true
            }
            self.restaurantDetailasTableview.reloadData()
        default:
            print("Do nothing")
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
//    {
//        return 1.0
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
//    {
//        return 1.0
//    }
    
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
