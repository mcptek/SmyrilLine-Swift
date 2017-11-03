//
//  RestaurantViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/24/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage

class RestaurantViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var activityIndicatorView: UIActivityIndicatorView!
    var restaurantsArray: [ObjectSample]?
    
    @IBOutlet weak var restauranttableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
       self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.restauranttableview.estimatedRowHeight = 220
        self.restauranttableview.rowHeight = UITableViewAutomaticDimension


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.attachToScrollView(self.restauranttableview)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.reset()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.navigationController?.navigationBar.backItem?.title = ""
        self.CallRestaurantAPI()
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
    func CallRestaurantDetailsAPI(restaurantId: String) {
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.restaurantParentPath + "/Eng" + "/" + restaurantId , method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<RestaurantDetailsInfo>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "restaurantDetails") as! RestaurantDetailsViewController
                        vc.restaurantDetailsObject = response.result.value
                        self.navigationController?.pushViewController(vc, animated:true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func CallRestaurantAPI() {
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.restaurantParentPath + "/Eng", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[RestaurantInfo]>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.restaurantsArray = response.result.value?[0].name
                        self.restauranttableview.reloadData()
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.restaurantsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantTableViewCell
        cell.restaurantNameLabel.text = self.restaurantsArray?[indexPath.section].name
        if let imageUrlStr = self.restaurantsArray?[indexPath.section].imageUrl
        {
            cell.restaurantImageView.sd_setShowActivityIndicatorView(true)
            cell.restaurantImageView.sd_setIndicatorStyle(.gray)
            cell.restaurantImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))

        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let restaurantId = self.restaurantsArray?[indexPath.section].objectId {
            self.CallRestaurantDetailsAPI(restaurantId: restaurantId)
        }
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
