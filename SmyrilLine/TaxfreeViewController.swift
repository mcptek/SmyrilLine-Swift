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
    
    var myHeaderView: MyTaxfreeScrollViewHeader!
    var scrollView: MXScrollView!
    var shopObject: TaxFreeShopInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.myHeaderView = Bundle.main.loadNibNamed("TaxfreeParallaxHeaderView", owner: self, options: nil)?.first as? UIView as! MyTaxfreeScrollViewHeader
        self.myTaxfreeCollectionView.parallaxHeader.view = self.myHeaderView
        self.myTaxfreeCollectionView.parallaxHeader.height = 250
        self.myTaxfreeCollectionView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        self.myTaxfreeCollectionView.parallaxHeader.minimumHeight = 50
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.CallTaxFreeShopAPI()
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
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taxfreeCell", for: indexPath) as! TaxfreeCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
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
            return CGSize(width: 186, height: 219)
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

    func CallTaxFreeShopAPI() {
        
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.taxFreeShopParentPath + "/Eng", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<TaxFreeShopInfo>) in
                
                switch response.result
                {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.shopObject = response.result.value
                        if let imageUrlStr = self.shopObject?.shopImageUrlStr
                        {
                            //self.taxFreeShopHeaderImageview.sd_setShowActivityIndicatorView(true)
                            //self.taxFreeShopHeaderImageview.sd_setIndicatorStyle(.gray)
                            //self.myCustomView.taxFreeHeaderImageView.sd_setImage(with: URL(string: UrlMCP.server_base_url + imageUrlStr), placeholderImage: UIImage.init(named: ""))
                        }
                        
//                        if let location = self.shopObject?.shopLocation
//                        {
//                            self.shopLocationLabel.text = location
//                        }
//                        
//                        if let time = self.shopObject?.shopOpeningClosingTime
//                        {
//                            self.shopOPeningClosingTimeLabel.text = time
//                        }
                        
                    }
                case .failure:
                    self.showAlert(title: "Error", message: (response.result.error?.localizedDescription)!)
                }
                self.myTaxfreeCollectionView.reloadData()
        }
    }

}
