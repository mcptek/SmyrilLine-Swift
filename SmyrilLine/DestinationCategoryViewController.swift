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

class DestinationCategoryViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var destinationCategoryCollectionView: UICollectionView!
    
    var destinationCategoryArray: TaxFreeShopInfo?
    
    var destinationId:String?
    var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
    
    func CallDestinationCategoryAPI() {
        self.activityIndicatorView.startAnimating()
        Alamofire.request(UrlMCP.server_base_url + UrlMCP.destinationParentPath + "/Eng/" + self.destinationId!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseObject { (response: DataResponse<TaxFreeShopInfo>) in
                self.activityIndicatorView.stopAnimating()
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200
                    {
                        self.destinationCategoryArray = response.result.value
                        self.destinationCategoryCollectionView.reloadData()
                       // self.destinaionArray = response.result.value?[0].name
                        //self.destinationTableview.reloadData()
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.destinationCategoryArray?.itemArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "destinationCategoryCell", for: indexPath) as! DestinationCategoryCollectionViewCell
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
        return CGSize(width: 150, height: 150)
    }



}
