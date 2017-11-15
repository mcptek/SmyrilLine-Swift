//
//  SettingViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/9/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    

    var expandCollapseArrau = [false,false]
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.settingsTableView.estimatedRowHeight = 120
        self.settingsTableView.rowHeight = UITableViewAutomaticDimension
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.expandCollapseArrau[section] {
                return 2
            }
            else {
                return 1
            }
        default:
            if self.expandCollapseArrau[section] {
                return 1
            }
            else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingHeaderCell", for: indexPath) as! SettingsHeaderTableViewCell
            if indexPath.section == 0 {
                cell.headerTitleLabel.text = "Message filters"
            }
            else {
                cell.headerTitleLabel.text = "Language"
            }
            
            if self.expandCollapseArrau[indexPath.section] {
                cell.expandCollapseImageView.image = UIImage(named: "CollapseArrow")
            }
            else {
                cell.expandCollapseImageView.image = UIImage(named: "ExpandArrow")
            }
            cell.expandCollapseImageView.image = cell.expandCollapseImageView.image!.withRenderingMode(.alwaysTemplate)
            cell.expandCollapseImageView.tintColor = UIColor.lightGray
            cell.selectionStyle = .default
            return cell
        }
        else
        {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageFilterCell", for: indexPath) as! MessageFilterTableViewCell
                cell.ageGroupCollectionView.tag = 1010
                cell.ageGroupCollectionView.reloadData()
                cell.ageGroupCollectionViewHeight.constant = cell.ageGroupCollectionView.collectionViewLayout.collectionViewContentSize.height
                cell.ageGroupCollectionView.layoutIfNeeded()
                cell.genderCollectionView.tag = 1020
                cell.genderCollectionView.reloadData()
                cell.genderGroupCollectionViewHeight.constant = cell.genderCollectionView.collectionViewLayout.collectionViewContentSize.height
                cell.genderCollectionView.layoutIfNeeded()
               // cell.containerHeight.constant = cell.ageGroupCollectionViewHeight.constant + cell.genderGroupCollectionViewHeight.constant + 110 + 20
                cell.layoutIfNeeded()
                self.settingsTableView.layoutIfNeeded()
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageFilterCell", for: indexPath) as! SettingsHeaderTableViewCell
                //        cell.mealCollectionView.tag = indexPath.section + 1000
                //        cell.layoutIfNeeded()
                //        cell.mealCollectionView.reloadData()
                //        cell.mealCollectionViewHeight.constant = cell.mealCollectionView.collectionViewLayout.collectionViewContentSize.height
                //        cell.mealCollectionView.layoutIfNeeded()
                //        cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if self.expandCollapseArrau[indexPath.section] {
                self.expandCollapseArrau[indexPath.section] = false
            }
            else {
                self.expandCollapseArrau[indexPath.section] = true
            }
            self.settingsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
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
        switch collectionView.tag {
        case 1010:
            return 4
        case 1020:
            return 3
        default:
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView.tag == 1010 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ageCollectionCell", for: indexPath) as! AgegroupCollectionViewCell
            if indexPath.row == 0 {
                cell.ageGroupImageView.image = UIImage.init(named: "Adult from 15 year")
                cell.ageTitleLabel.text = "Adult"
                cell.ageDescriptionLabel.text = "From 15 year"
                cell.ageDescriptionLabelHeight.constant = 21
            }
            else if indexPath.row == 1 {
                cell.ageGroupImageView.image = UIImage.init(named: "Child 12 - 15 year")
                cell.ageTitleLabel.text = "Child"
                cell.ageDescriptionLabel.text = "15 - 18 year"
                cell.ageDescriptionLabelHeight.constant = 21
            }
            else if indexPath.row == 2 {
                cell.ageGroupImageView.image = UIImage.init(named: "Child 3 - 11 year")
                cell.ageTitleLabel.text = "Child"
                cell.ageDescriptionLabel.text = "3 - 11 year"
                cell.ageDescriptionLabelHeight.constant = 21
            }
            else {
                cell.ageGroupImageView.image = UIImage.init(named: "All")
                cell.ageTitleLabel.text = "All"
                cell.ageDescriptionLabel.text = nil
                cell.ageDescriptionLabelHeight.constant = 0
            }
            //cell.backgroundColor = UIColor.lightGray
            return cell
        }
        else {//if collectionView.tag == 1020 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genderCollectionCell", for: indexPath) as! GenderGroupCollectionViewCell
            if indexPath.row == 0 {
                cell.genderImageView.image = UIImage.init(named: "Male")
                cell.genderNameTitleLabel.text = "Male"
            }
            else if indexPath.row == 1 {
                cell.genderImageView.image = UIImage.init(named: "Female")
                cell.genderNameTitleLabel.text = "Female"
            }
            else {
                cell.genderImageView.image = UIImage.init(named: "Both")
                cell.genderNameTitleLabel.text = "Both"
            }
            //cell.backgroundColor = UIColor.lightGray
            return cell
        }
//        else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealCell", for: indexPath) as! MealCollectionViewCell
//            return cell
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
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
        return 8.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1010 {
            if indexPath.row == 3 {
                return CGSize(width: 95, height: 128)
            }
            else {
                return CGSize(width: 95, height: 128)
            }
        }
        else if collectionView.tag == 1020 {
            return CGSize(width: 95, height: 120)
        }
        else {
            return CGSize(width: 95, height: 128)
        }
        /*
        let deviceType = UIDevice.current.deviceType
        switch deviceType {
        case .iPhone5,.iPhone5S,.iPhone5C,.iPhoneSE:
            return CGSize(width: 95, height: 150)
        case .iPhone8Plus,.iPhone7Plus,.iPhone6SPlus,.iPhone6Plus:
            return CGSize(width: 125, height: 150)
        case .iPhone8,.iPhone7,.iPhone6S,.iPhone6:
            return CGSize(width: 110, height: 150)
        case .iPhoneX:
            return CGSize(width: 110, height: 150)
        case .iPhone4S, .iPhone4:
            return CGSize(width: 90, height: 150)
        default:
            return CGSize(width: 125, height: 150)
        }
 */
        
    }

}
