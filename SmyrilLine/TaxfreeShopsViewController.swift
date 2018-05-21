//
//  TaxfreeShopsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 21/5/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage

class TaxfreeShopsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var taxfreeTableview: UITableView!
    var activityIndicatorView: UIActivityIndicatorView!
    var shopObject: [TaxFreeShopInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        self.navigationItem.title = NSLocalizedString("Tax Free", comment: "")
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.taxfreeTableview.estimatedRowHeight = 220
        self.taxfreeTableview.rowHeight = UITableViewAutomaticDimension

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.shopObject = nil
        self.CallTaxfreeShopAPI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "taxfreeParticularShop"
        {
            let vc = segue.destination as! TaxfreeViewController
            let indexPath = self.taxfreeTableview.indexPathForSelectedRow
            if self.shopObject != nil {
                vc.shopObject = self.shopObject?[(indexPath?.section)!]
            }
        }
    }
    
    
    func CallTaxfreeShopAPI() {
        self.activityIndicatorView.startAnimating()
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
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.taxFreeShopParentPath + language + "\(String(describing: shipId))", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[TaxFreeShopInfo]>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        if response.result.value?.isEmpty == false {
                            self.shopObject = response.result.value
                        }
                        if self.shopObject != nil {
                            self.taxfreeTableview.reloadData()
                        }
                    }
                case .failure:
                    self.showAlert(title: "Error", message: (response.result.error?.localizedDescription)!)
                }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.shopObject?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taxFreeCell", for: indexPath) as! RestaurantTableViewCell
        if let name = self.shopObject![indexPath.section].shopName {
            cell.restaurantNameLabel.text = name
        }
        if let imageUrlStr = self.shopObject![indexPath.section].shopImageUrlStr
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            cell.restaurantImageView.sd_setShowActivityIndicatorView(true)
            cell.restaurantImageView.sd_setIndicatorStyle(.gray)
            cell.restaurantImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
            
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        if let restaurantId = self.restaurantsArray?[indexPath.section].objectId {
//            self.CallRestaurantDetailsAPI(restaurantId: restaurantId)
//        }
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
        if section == 0
        {
            vw.backgroundColor = UIColor.darkGray
        }
        else
        {
            vw.backgroundColor = UIColor.clear
        }
        return vw
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        
        return vw
    }

}
