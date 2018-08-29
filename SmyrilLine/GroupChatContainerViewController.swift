//
//  GroupChatContainerViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 28/8/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class GroupChatContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var groupChatObject: chatSessionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.groupChatObject?.groupName
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
        if segue.identifier == "groupMenu" {
            let vc = segue.destination as! GroupChatMenuViewController
            vc.groupChatObject = self.groupChatObject
        }
    }
    

    @IBAction func menuBarButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "groupMenu", sender: self)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.groupChatObject?.memberDevices?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupContainerUserCell", for: indexPath) as! UserListCollectionViewCell
        cell.unreadMessageLabel.isHidden = true
        cell.userNameLabel.backgroundColor = UIColor.clear
        cell.userNameLabel.textColor = UIColor.white
        cell.userImageView.backgroundColor = UIColor.white
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.height / 2
        cell.userImageView.clipsToBounds = true
        cell.onlineTrackerImageView.isHidden = true
        if let status = self.groupChatObject?.memberDevices![indexPath.row].status {
            if status == 1 {
                cell.onlineTrackerImageView.isHidden = false
            }
        }
        if let name = self.groupChatObject?.memberDevices![indexPath.row].name {
            if let decodedname = name.base64Decoded() {
                cell.userNameLabel.text = decodedname
            }
            else {
                cell.userNameLabel.text = name
            }
        }
        else {
            cell.userNameLabel.text = "No name Found"
        }
        
        if let imageUrlStr = self.groupChatObject?.memberDevices![indexPath.row].imageUrl
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
//        let CellWidth = 100.0
//        let CellCount = Double(self.groupChatObject?.memberDevices?.count ?? 0)
//        let CellSpacing = 8.0
//
//        let totalCellWidth = CellWidth * CellCount
//        let totalSpacingWidth = CellSpacing * (CellCount - 1)
//
//        let leftInset = (collectionView.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
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
