//
//  DestinationViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/24/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage

class DestinationViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var destinationTableview: UITableView!
    var destinaionArray:[ObjectSample]?
    
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.destinationTableview.estimatedRowHeight = 150
        self.destinationTableview.rowHeight = UITableViewAutomaticDimension
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.CallDestinationAPI()
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
    
    func CallDestinationAPI() {
        self.activityIndicatorView.startAnimating()
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + "/Eng", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[DestinationInfo]>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.destinaionArray = response.result.value?[0].name
                        self.destinationTableview.reloadData()
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.destinaionArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCell", for: indexPath) as! DestinationTableViewCell
        cell.destinationName.text = self.destinaionArray?[indexPath.section].name
        if let imageUrlStr = self.destinaionArray?[indexPath.section].imageUrl
        {
            cell.destinationImageView.sd_setShowActivityIndicatorView(true)
            cell.destinationImageView.sd_setIndicatorStyle(.gray)
            cell.destinationImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
            
        }
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
