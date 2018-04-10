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


class DestinationViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var destinationTableview: UITableView!
    
    var destinaionArray:[DestinationChildren]?
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
//        let navigationBar = navigationController!.navigationBar
//        navigationBar.barColor = UIColor(colorLiteralRed: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.destinationTableview.estimatedRowHeight = 150
        self.destinationTableview.rowHeight = UITableViewAutomaticDimension
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.navigationController?.navigationBar.backItem?.title = ""
        self.CallDestinationAPI()
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
        
        if segue.identifier == "destinationCategory"
        {
            let vc = segue.destination as! DestinationCategoryViewController
            let indexPath = self.destinationTableview.indexPathForSelectedRow
            vc.destinationId = self.destinaionArray?[(indexPath?.section)!].childrenId
            vc.destinationName = self.destinaionArray?[(indexPath?.section)!].name
            //vc.attatchFileName = self.destinaionArray?[(indexPath?.section)!].attatchFileName
           // vc.attatchFileUrl = self.destinaionArray?[(indexPath?.section)!].attatchFileUrl
        }
    }

    
    func CallDestinationAPI() {
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
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + language + "\(String(describing: shipId))", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<DestinationInfo>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.destinaionArray = response.result.value?.itemArray
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
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            cell.destinationImageView.sd_setShowActivityIndicatorView(true)
            cell.destinationImageView.sd_setIndicatorStyle(.gray)
            cell.destinationImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
            
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
