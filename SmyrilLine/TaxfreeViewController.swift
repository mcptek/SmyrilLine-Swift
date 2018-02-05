//
//  TaxfreeViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/25/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SDWebImage
import MXParallaxHeader

class TaxfreeViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var myTaxfreeCollectionView: UICollectionView!
    
    var myHeaderView: TaxfreeHeader!
    var scrollView: MXScrollView!
    var productInfoCategoryId: String?
    var activityIndicatorView: UIActivityIndicatorView!
    var shopObject: TaxFreeShopInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        self.title = "Tax Free"
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeHeader", owner: self, options: nil)?.first as? UIView as! TaxfreeHeader
        self.myTaxfreeCollectionView.parallaxHeader.view = self.myHeaderView
        self.myTaxfreeCollectionView.parallaxHeader.height = 250
        self.myTaxfreeCollectionView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.myTaxfreeCollectionView.parallaxHeader.minimumHeight = 50
        
        //self.myTaxfreeCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.CallTaxfreeShopAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if (self.shopObject?.itemArray?.isEmpty == true) {
            self.myTaxfreeCollectionView.setEmptyMessage("There is no item available now.")
        } else {
            self.myTaxfreeCollectionView.restore()
        }
        return self.shopObject?.itemArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taxfreeCell", for: indexPath) as! TaxfreeCollectionViewCell
        if let productName = self.shopObject?.itemArray?[indexPath.row].name
        {
            cell.productNameLabel.text = productName
        }
        else
        {
            cell.productNameLabel.text = nil
        }
        
        if let productHeader = self.shopObject?.itemArray?[indexPath.row].objectHeader
        {
            cell.productHeaderLabel.text = productHeader
        }
        else
        {
            cell.productHeaderLabel.text = nil
        }
        
        
//        if let priceObject = self.shopObject?.itemArray?[indexPath.row].objectPrice
//        {
//            var price = priceObject.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
//            price = "€" + price
//            let splittedStringsArray = price.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
//            if let firstString = splittedStringsArray.first, let secondString = splittedStringsArray.last
//            {
//                let numericPart = String(describing: firstString)
//                let fractionPart = String(describing: secondString)
//                let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
//                let scriptFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
//                let stringwithSquare = numericPart.attributedStringWithSuperscript(fractionPart, mainStringFont: mainFont, subStringFont: scriptFont, offSetFromBaseLine: 10)
//                cell.productPriceLabel.attributedText = stringwithSquare
//            }
//            else
//            {
//                cell.productPriceLabel.text = price
//            }
//        }
        if let priceObject = self.shopObject?.itemArray?[indexPath.row].objectPrice
        {
            var price = priceObject.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
            //price = "€" + price
            if price.characters.contains(",") {
                let splittedStringsArray = price.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
                if let firstString = splittedStringsArray.first, let secondString = splittedStringsArray.last
                {
                    let numericPart = String(describing: firstString)
                    let fractionPart = String(describing: secondString)
                    let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                    let scriptFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
                    let stringwithSquare = numericPart.attributedStringWithSuperscript(fractionPart, mainStringFont: mainFont, subStringFont: scriptFont, offSetFromBaseLine: 10)
                    cell.productPriceLabel.attributedText = stringwithSquare
                }
                else
                {
                    let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                    cell.productPriceLabel.text = price
                    cell.productPriceLabel.font = mainFont
                    
                }
            }
            else {
                let mainFont:UIFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                cell.productPriceLabel.text = price
                cell.productPriceLabel.font = mainFont
            }
        }
        else
        {
            cell.productPriceLabel.text = nil
        }
        
        if let imageUrlStr = self.shopObject?.itemArray?[indexPath.row].imageUrl
        {
            let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
            cell.productImageView.sd_setShowActivityIndicatorView(true)
            cell.productImageView.sd_setIndicatorStyle(.gray)
            cell.productImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let objectId = self.shopObject?.itemArray?[indexPath.row].objectId
        {
            self.CallTaxfreeShopDetailsAPIwithObjectId(objectId: objectId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 8.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let screenHeight = UIScreen.main.bounds.size.height
        switch screenHeight {
        case 480:
            return CGSize(width: 140, height: 219)
        case 568:
            return CGSize(width: 140, height: 219)
        case 667:
            return CGSize(width: 166, height: 219)
        case 736:
            return CGSize(width: 186, height: 225)
        case 480:
            return CGSize(width: 140, height: 219)
        default:
            return CGSize(width: 186, height: 219)
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

    func CallTaxfreeShopDetailsAPIwithObjectId(objectId: String) {
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let shipId = UserDefaults.standard.value(forKey: "CurrentSelectedShipdId") as! String
        
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.taxFreeShopParentPath + "/Eng/\(String(describing: shipId))/\(objectId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[ShopObject]>) in
                self.activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextScene = storyBoard.instantiateViewController(withIdentifier: "taxfreeShopDetails") as! TaxfreeDetailsViewController
                        nextScene.productName = response.result.value?[0].name
                        nextScene.productPrice = response.result.value?[0].objectPrice
                        nextScene.productImageUrl = response.result.value?[0].imageUrl
                        nextScene.productDetails = response.result.value?[0].objectHeader
                        self.navigationController?.pushViewController(nextScene, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }

    func CallTaxfreeShopAPI() {
        self.activityIndicatorView.startAnimating()
        let shipId = UserDefaults.standard.value(forKey: "CurrentSelectedShipdId") as! String
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.taxFreeShopParentPath + "/Eng/\(String(describing: shipId))", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseArray { (response: DataResponse<[TaxFreeShopInfo]>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        if response.result.value?.isEmpty == false {
                            self.shopObject = response.result.value?[0]
                            if let imageUrlStr = self.shopObject?.shopImageUrlStr
                            {
                                let replaceStr = imageUrlStr.replacingOccurrences(of: " ", with: "%20")
                                self.myHeaderView.headerImageView.sd_setShowActivityIndicatorView(true)
                                self.myHeaderView.headerImageView.sd_setIndicatorStyle(.gray)
                                self.myHeaderView.headerImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + replaceStr), placeholderImage: UIImage.init(named: "placeholder"))
                            }
                            
                            if let time = self.shopObject?.shopOpeningClosingTime
                            {
                                self.myHeaderView.headerTimeLabel.text = time
                            }
                            
                            if let location = self.shopObject?.shopLocation
                            {
                                self.myHeaderView.headerLocationLabel.text = location
                            }
                        }
                        else {
                            self.myHeaderView.headerImageView.image = nil
                            self.myHeaderView.headerTimeLabel.text = nil
                            self.myHeaderView.headerLocationLabel.text = nil
                            self.shopObject?.itemArray = nil
                        }
                        self.myTaxfreeCollectionView.reloadData()
                    }
                case .failure:
                    self.showAlert(title: "Error", message: (response.result.error?.localizedDescription)!)
                }
        }
    }

}
