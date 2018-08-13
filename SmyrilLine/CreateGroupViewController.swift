//
//  CreateGroupViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var allUser = [User]()
    var SelectedUserList = [String:Bool]()
    
    
    @IBOutlet weak var allUserCollectionview: UICollectionView!
    
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
        return self.allUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allUser", for: indexPath) as! AllUserCollectionViewCell
        if self.SelectedUserList[self.allUser[indexPath.row].deviceId!] != nil {
            if self.SelectedUserList[self.allUser[indexPath.row].deviceId!]! {
                cell.userSelectionImageview.image = UIImage.init(named: "settingSelect")
            }
            else {
                cell.userSelectionImageview.image = nil
            }
        }
        else {
            cell.userSelectionImageview.image = nil
        }
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
        cell.userImageView.clipsToBounds = true
        if let name = self.allUser[indexPath.row].name {
            if let decodedname = name.base64Decoded() {
                cell.usernameLabel.text = decodedname
            }
            else {
                cell.usernameLabel.text = name
            }
        }
        else {
            cell.usernameLabel.text = "No name Found"
        }
        
        if let imageUrlStr = self.allUser[indexPath.row].imageUrl
        {
            cell.userImageView.sd_setShowActivityIndicatorView(true)
            cell.userImageView.sd_setIndicatorStyle(.gray)
            cell.userImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: "UserPlaceholder"))
        }
        else {
            cell.userImageView.image = UIImage.init(named: "UserPlaceholder")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if self.SelectedUserList[self.allUser[indexPath.row].deviceId!] != nil {
            if self.SelectedUserList[self.allUser[indexPath.row].deviceId!]! {
                self.SelectedUserList[self.allUser[indexPath.row].deviceId!] = false
            }
            else {
                self.SelectedUserList[self.allUser[indexPath.row].deviceId!] = true
            }
        }
        else {
            self.SelectedUserList[self.allUser[indexPath.row].deviceId!] = true
        }
        let userIndexPath = IndexPath.init(row: indexPath.row, section: 0)
        self.allUserCollectionview.reloadItems(at: [userIndexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(8.0, 0.0, 8.0, 8.0)
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
        return CGSize(width: 100, height: 138)
    }
}
