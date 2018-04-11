//
//  SeventhPageViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 29/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage

class SeventhPageViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    var activityIndicatorView: UIActivityIndicatorView!
    var shipArray: [ShipObjectInfo]?
    var currentSelectedLanguage = 0
    var currentSelectedShipId: String?
    
    @IBOutlet weak var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "CurrentSelectedLanguage") == nil
        {
            defaults.set(0, forKey: "CurrentSelectedLanguage")
        }
        else
        {
            self.currentSelectedLanguage = defaults.value(forKey: "CurrentSelectedLanguage") as! Int
        }
        
        if defaults.value(forKey: "CurrentSelectedShipdId") != nil
        {
            self.currentSelectedShipId = (defaults.value(forKey: "CurrentSelectedShipdId") as! String)
//            defaults.set("1", forKey: "CurrentSelectedShipdId")
//            self.currentSelectedShipId = "1"
        }
//        else
//        {
//            self.currentSelectedShipId = (defaults.value(forKey: "CurrentSelectedShipdId") as! String)
//        }
        
        self.CallShipIdFromAPI()
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
    
    @IBAction func StartButtonAction(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "GuideScreen")
        self.dismiss(animated: true, completion: nil)
    }
    
    func CallShipIdFromAPI() {
        self.activityIndicatorView.startAnimating()
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.ShipChoosingParentPath + "/Eng/1", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[ShipObjectInfo]>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.shipArray = response.result.value
                        if self.shipArray?.isEmpty == false {
                            if UserDefaults.standard.value(forKey: "CurrentSelectedShipdId") == nil
                            {
                                self.currentSelectedShipId = self.shipArray![0].shipId
                                UserDefaults.standard.set(self.currentSelectedShipId, forKey: "CurrentSelectedShipdId")
                            }
                        }
                        self.settingTableView.reloadData()
                    }
                case .failure:
                    self.showAlert(title: "Error", message: (response.result.error?.localizedDescription)!)
                }
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "languageTableCell", for: indexPath) as! LanguageTableViewCell
            cell.languageCollectionView.tag = 1000
            cell.languageCollectionView.reloadData()
            //cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.65)
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shipTableCell", for: indexPath) as! ShipTableViewCell
            cell.shipCollectionview.tag = 2000
            cell.shipCollectionview.reloadData()
            //cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.65)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 5.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 5.0
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView.tag == 1000 {
            return 4
        }
        else {
            return self.shipArray?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView.tag == 1000 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "languageCell", for: indexPath) as! LanguageCollectionViewCell
            switch indexPath.row {
            case 0:
                cell.languageTitleLabel.text = "English"
                cell.languageImageView.image = UIImage.init(named: "england")
            case 1:
                cell.languageTitleLabel.text = "German"
                cell.languageImageView.image = UIImage.init(named: "germany")
            case 2:
                cell.languageTitleLabel.text = "Faroese"
                cell.languageImageView.image = UIImage.init(named: "faroe-islands")
            default:
                cell.languageTitleLabel.text = "Danish"
                cell.languageImageView.image = UIImage.init(named: "denmark")
            }
            //cell.backgroundColor = UIColor.clear
            
            if self.currentSelectedLanguage == indexPath.row {
                cell.containerView.layer.borderWidth = 1.5
                let color = UIColor(red: 12.0/255, green: 131.0/255, blue: 203.0/255, alpha: 1.0)
                cell.containerView.layer.borderColor = color.cgColor
                // Initialization code
               // cell.containerView.layer.cornerRadius = 2
                //cell.containerView.layer.masksToBounds = true
            }
            else {
                cell.containerView.layer.borderWidth = 0
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shipCell", for: indexPath) as! ShipCollectionViewCell
            if let imageUrlStr = self.shipArray![indexPath.row].shipImageUrlStr
            {
                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                
                cell.shipImageView.sd_setShowActivityIndicatorView(true)
                cell.shipImageView.sd_setIndicatorStyle(.gray)
                cell.shipImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                cell.shipImageView.layer.cornerRadius = cell.shipImageView.frame.size.height / 2
                cell.shipImageView.layer.masksToBounds = true
            }
            
            if let name = self.shipArray![indexPath.row].name
            {
                cell.shipTitleLabel.text = name
            }
            
            if let shipId = self.shipArray![indexPath.row].shipId
            {
                if shipId == self.currentSelectedShipId {
                    cell.containerView.layer.borderWidth = 1.5
                    let color = UIColor(red: 12.0/255, green: 131.0/255, blue: 203.0/255, alpha: 1.0)
                    cell.containerView.layer.borderColor = color.cgColor
                }
                else {
                    cell.containerView.layer.borderWidth = 0
                }
            }
            
           // cell.backgroundColor = UIColor.clear
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView.tag == 1000 {
            self.currentSelectedLanguage = indexPath.row
            UserDefaults.standard.set(self.currentSelectedLanguage, forKey: "CurrentSelectedLanguage")
            collectionView.reloadData()
        }
        else {
            self.currentSelectedShipId = self.shipArray![indexPath.row].shipId
            UserDefaults.standard.set(self.currentSelectedShipId, forKey: "CurrentSelectedShipdId")
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 16.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView.tag == 1000 {
            return CGSize(width: 130, height: 140)
        }
        else {
            return CGSize(width: 130, height: 140)
        }
    }
    
}
