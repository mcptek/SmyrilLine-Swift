//
//  MainMenuViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/22/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    let itemTitleArray = ["View Booking", "Tax Free Shops", "Offers", "Restaurants", "Ship Tracker", "Inbox", "Destinations", "Settings", "Ship Info", "", "Help"]
    let itemImageNameArray = ["booking", "Taxfree", "offer", "restaurent", "Shiptrackers", "Inboxs", "destinations", "settingss", "Ship-Info", "", "Helps"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.itemTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! MainMenuCollectionViewCell
        cell.itemTitleLabel.text = self.itemTitleArray[indexPath.row]
        cell.itemImageView.image = UIImage.init(named: self.itemImageNameArray[indexPath.row])
        if self.itemImageNameArray[indexPath.row] == ""
        {
            cell.imageContainerView.backgroundColor = nil
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        switch indexPath.row {
        case 4:
            performSegue(withIdentifier: "shipTracker", sender: self)
        default:
            print("Do nothing")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let screenHeight = UIScreen.main.bounds.size.height
        if(screenHeight == 480) {
            //iPhone 4/4S
            return CGSize(width: 80, height: 105)
            
        } else if (screenHeight == 568) {
            //iPhone 5/5S/SE
            return CGSize(width: 80, height: 105)
        } else if (screenHeight == 667) {
            //iPhone 6/6S
            return CGSize(width: 100, height: 125)
            
        } else if (screenHeight == 736) {
            //iPhone 6+, 6S+
            return CGSize(width: 100, height: 125)
            
        } else {
            return CGSize(width: 100, height: 125)
        }
    }


}
