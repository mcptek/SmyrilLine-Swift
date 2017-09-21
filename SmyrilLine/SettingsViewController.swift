//
//  SettingsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 9/18/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import Device_swift

class SettingsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    let ageGroupArray = ["Adult (from 15 yr)","Child 12 - 15 yr","Child 3 - 11 yr","All"]
    let genderArray = ["Male","Female","Both"]
    var settingDic = [String:Bool]()
    
    @IBOutlet weak var settingsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Settings"
        self.loadSettingsdata()
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
    
    func loadSettingsdata()  {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "Adult (from 15 yr)") is Bool
        {
            self.settingDic["Adult (from 15 yr)"] = defaults.value(forKey: "Adult (from 15 yr)") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Adult (from 15 yr)")
            self.settingDic["Adult (from 15 yr)"] = true
        }
        
        if defaults.value(forKey: "Child 12 - 15 yr") is Bool
        {
            self.settingDic["Child 12 - 15 yr"] = defaults.value(forKey: "Child 12 - 15 yr") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Child 12 - 15 yr")
            self.settingDic["Child 12 - 15 yr"] = true
        }
        
        if defaults.value(forKey: "Child 3 - 11 yr") is Bool
        {
            self.settingDic["Child 3 - 11 yr"] = defaults.value(forKey: "Child 3 - 11 yr") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Child 3 - 11 yr")
            self.settingDic["Child 3 - 11 yr"] = true
        }
        
        if defaults.value(forKey: "All") is Bool
        {
            self.settingDic["All"] = defaults.value(forKey: "All") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "All")
            self.settingDic["All"] = true
        }
        
        if defaults.value(forKey: "Male") is Bool
        {
            self.settingDic["Male"] = defaults.value(forKey: "Male") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Male")
            self.settingDic["Male"] = true
        }
        
        if defaults.value(forKey: "Female") is Bool
        {
            self.settingDic["Female"] = defaults.value(forKey: "Female") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Female")
            self.settingDic["Female"] = true
        }
        
        if defaults.value(forKey: "Both") is Bool
        {
            self.settingDic["Both"] = defaults.value(forKey: "Both") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Both")
            self.settingDic["Both"] = true
        }
        self.settingsCollectionView.reloadData()
    }
    
    @IBAction func settingsSaveAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        var ageGroup = ""
        var genderGroup = ""
        if self.settingDic["All"]!
        {
            ageGroup = "all"
        }
        else
        {
            if self.settingDic["Adult (from 15 yr)"]!
            {
                ageGroup = "adult"
            }
            if self.settingDic["Child 12 - 15 yr"]!
            {
                if ageGroup.characters.count > 0
                {
                    ageGroup = ageGroup + "," + "child18"
                }
                else
                {
                    ageGroup = "child18"
                }
            }
            
            if self.settingDic["Child 3 - 11 yr"]!
            {
                if ageGroup.characters.count > 0
                {
                    ageGroup = ageGroup + "," + "child15"
                }
                else
                {
                    ageGroup = "child15"
                }
            }
        }
        
        if self.settingDic["Both"]!
        {
            genderGroup = "both"
        }
        else
        {
            if self.settingDic["Male"]!
            {
                genderGroup = "male"
            }
            if self.settingDic["Female"]!
            {
                if genderGroup.characters.count > 0
                {
                    genderGroup = genderGroup + "," + "female"
                }
                else
                {
                    genderGroup = "female"
                }
            }
        }
        
        if ageGroup.characters.count > 0 && genderGroup.characters.count > 0
        {
            self.saveMessageSettings()
            defaults.set(ageGroup, forKey: "ageSettings")
            defaults.set(genderGroup, forKey: "genderSettings")
            StreamingConnection.sharedInstance.connection.stop()
            if #available(iOS 10.0, *) {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.createSocketConnection()
            } else {
                // Fallback on earlier versions
            }
        }
        else
        {
            var message = ""
            if ageGroup.characters.count == 0
            {
                message = "Please select an age group."
            }
            else if genderGroup.characters.count == 0
            {
                message = "Please select a gender group."
            }
            self.showAlert(title: "Error", message: message)
        }
    }
    
    func saveMessageSettings()  {
        let defaults = UserDefaults.standard
        defaults.set(self.settingDic["Adult (from 15 yr)"], forKey: "Adult (from 15 yr)")
        defaults.set(self.settingDic["Child 12 - 15 yr"], forKey: "Child 12 - 15 yr")
        defaults.set(self.settingDic["Child 3 - 11 yr"], forKey: "Child 3 - 11 yr")
        defaults.set(self.settingDic["All"], forKey: "All")
        defaults.set(self.settingDic["Male"], forKey: "Male")
        defaults.set(self.settingDic["Female"], forKey: "Female")
        defaults.set(self.settingDic["Both"], forKey: "Both")
        self.displayToast(alertMsg: "Age group and gender recipient saved.")
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 4
        }
        else
        {
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsCell", for: indexPath) as! SettingsCollectionViewCell
        if indexPath.section == 0
        {
            cell.categoryNameLabel.text = self.ageGroupArray[indexPath.row]
            cell.categoryImageView.image = UIImage.init(named: self.ageGroupArray[indexPath.row])
            if self.settingDic[self.ageGroupArray[indexPath.row]]!
            {
                cell.transparentImageView.backgroundColor = UIColor.black
                cell.categorySelectionImageView.isHidden = false
            }
            else
            {
                cell.transparentImageView.backgroundColor = UIColor.white
                cell.categorySelectionImageView.isHidden = true
            }
        }
        else
        {
            cell.categoryNameLabel.text = self.genderArray[indexPath.row]
            cell.categoryImageView.image = UIImage.init(named: self.genderArray[indexPath.row])
            if self.settingDic[self.genderArray[indexPath.row]]!
            {
                cell.transparentImageView.backgroundColor = UIColor.black
                cell.categorySelectionImageView.isHidden = false
            }
            else
            {
                cell.transparentImageView.backgroundColor = UIColor.white
                cell.categorySelectionImageView.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        {
            if indexPath.row == 3
            {
                if self.settingDic[self.ageGroupArray[indexPath.row]]!
                {
                    self.settingDic[self.ageGroupArray[indexPath.row]] = false
                    self.settingDic[self.ageGroupArray[0]] = false
                    self.settingDic[self.ageGroupArray[1]] = false
                    self.settingDic[self.ageGroupArray[2]] = false
                }
                else
                {
                    self.settingDic[self.ageGroupArray[indexPath.row]] = true
                    self.settingDic[self.ageGroupArray[0]] = true
                    self.settingDic[self.ageGroupArray[1]] = true
                    self.settingDic[self.ageGroupArray[2]] = true
                }
            }
            else
            {
                if self.settingDic[self.ageGroupArray[indexPath.row]]!
                {
                    self.settingDic[self.ageGroupArray[indexPath.row]] = false
                    self.settingDic[self.ageGroupArray[3]] = false
                }
                else
                {
                    self.settingDic[self.ageGroupArray[indexPath.row]] = true
                }
            }
            if self.settingDic[self.ageGroupArray[0]]! && self.settingDic[self.ageGroupArray[1]]!  && self.settingDic[self.ageGroupArray[2]]!
            {
                self.settingDic[self.ageGroupArray[3]] = true
            }
            
        }
        else
        {
            if indexPath.row == 2
            {
                if self.settingDic[self.genderArray[indexPath.row]]!
                {
                    self.settingDic[self.genderArray[indexPath.row]] = false
                    self.settingDic[self.genderArray[0]] = false
                    self.settingDic[self.genderArray[1]] = false
                }
                else
                {
                    self.settingDic[self.genderArray[indexPath.row]] = true
                    self.settingDic[self.genderArray[0]] = true
                    self.settingDic[self.genderArray[1]] = true
                }
            }
            else
            {
                if self.settingDic[self.genderArray[indexPath.row]]!
                {
                    self.settingDic[self.genderArray[indexPath.row]] = false
                    self.settingDic[self.genderArray[2]] = false
                }
                else
                {
                    self.settingDic[self.genderArray[indexPath.row]] = true
                }
            }
            
            if self.settingDic[self.genderArray[0]]! && self.settingDic[self.genderArray[1]]!
            {
                self.settingDic[self.genderArray[2]] = true
            }
        }
        self.settingsCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width, height: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath as IndexPath) as! HeaderCollectionReusableView
            if indexPath.section == 0
            {
                headerView.titlaLabel.text = "Age group"
            }
            else
            {
                headerView.titlaLabel.text = "Gender"
            }
            headerView.backgroundColor = UIColor.clear
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerCell", for: indexPath as IndexPath)
            footerView.backgroundColor = UIColor.clear
            return footerView
            
        default:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerCell", for: indexPath as IndexPath)
            footerView.backgroundColor = UIColor.clear
            return footerView
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
        let deviceType = UIDevice.current.deviceType
        switch deviceType {
        case .iPhone6SPlus,.iPhone6Plus:
            return CGSize(width: 100, height: 120)
        case .iPhone6S,.iPhone6:
            return CGSize(width: 100, height: 120)
        default:
            return CGSize(width: 100, height: 120)
        }
    }

}
