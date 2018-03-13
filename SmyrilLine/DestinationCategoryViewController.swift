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
    var cellIndex = 1
    var destinationCategoryObject: GeneralCategory?
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var destinationId:String?
    var destinationName:String?
    var destinationCategoryId: String?
    var headerCurrentStatus = 0
    
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.title = self.destinationName
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        self.categoryTableview.estimatedRowHeight = 140
        self.categoryTableview.rowHeight = UITableViewAutomaticDimension
        
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.isHidden = false
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.attachToScrollView(self.categoryTableview)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.reset()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        self.navigationController?.navigationBar.backItem?.title = ""
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
    
    func CallDestinationCategoryDetailsAPI() {
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
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + language + "\(shipId)/\(self.destinationCategoryId!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<TaxFreeShopInfo>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextScene = storyBoard.instantiateViewController(withIdentifier: "destinationCategoryDetails") as! DestinationCategoryDetailsViewController
                        nextScene.destinationCategoryDetailsArray = response.result.value
                        self.navigationController?.pushViewController(nextScene, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func CallDestinationCategoryAPI() {
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
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + language + "\(shipId)/\(self.destinationId!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<GeneralCategory>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.destinationCategoryObject = response.result.value
                        if let imageUrlStr = self.destinationCategoryObject?.imageUrl
                        {
                            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                            self.myHeaderView.taxFreeHeaderImageView.sd_setShowActivityIndicatorView(true)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setIndicatorStyle(.gray)
                            self.myHeaderView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                        }
                        self.categoryTableview.reloadData()
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
        
        var totalCount = 1
        if let count = self.destinationCategoryObject?.itemArray?.count
        {
            totalCount += (count / 2 ) + (count % 2)
        }
        
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryHeaderCell", for: indexPath) as! CategoryHeaderTableViewCell
            cell.headerTitleLabel.text = self.destinationCategoryObject?.detailsDescription
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
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCategoryCell", for: indexPath) as! DestinationCategoryTableViewCell
            self.cellIndex = (indexPath.row - 1) * 2
            if let imageUrlStr = self.destinationCategoryObject?.itemArray?[self.cellIndex].imageUrl
            {
                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                cell.leftCategoryImageView.sd_setShowActivityIndicatorView(true)
                cell.leftCategoryImageView.sd_setIndicatorStyle(.gray)
                cell.leftCategoryImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                
            }
            if let categoryname = self.destinationCategoryObject?.itemArray?[self.cellIndex].name
            {
                cell.leftCategoryNameLabel.text = categoryname
            }
            if let categoryId = self.destinationCategoryObject?.itemArray?[self.cellIndex].childrenId
            {
                cell.leftContainerButton.tag = 1000 + Int(categoryId)!
                cell.leftContainerButton.addTarget(self, action: #selector(categoryDetailsButton(_:)), for: .touchUpInside)
            }
            self.cellIndex += 1
            if self.cellIndex < (self.destinationCategoryObject?.itemArray?.count)!
            {
                if let imageUrlStr = self.destinationCategoryObject?.itemArray?[self.cellIndex].imageUrl
                {
                    let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                    cell.rightContainerView.isHidden = false
                    cell.rightCategotyImageView.sd_setShowActivityIndicatorView(true)
                    cell.rightCategotyImageView.sd_setIndicatorStyle(.gray)
                    cell.rightCategotyImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                    
                }
                if let categoryname = self.destinationCategoryObject?.itemArray?[self.cellIndex].name
                {
                    cell.rightCategoryNameLabel.text = categoryname
                }
                if let categoryId = self.destinationCategoryObject?.itemArray?[self.cellIndex].childrenId
                {
                    cell.rightContainerButton.tag = 1000 + Int(categoryId)!
                    cell.rightContainerButton.addTarget(self, action: #selector(categoryDetailsButton(_:)), for: .touchUpInside)
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
        return 3.5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 3.5
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
    
    func categoryDetailsButton(_ sender : UIButton)  {
        self.destinationCategoryId = String(sender.tag - 1000)
        self.CallDestinationCategoryDetailsAPI()
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
        self.categoryTableview.reloadData()
        
    }

}
