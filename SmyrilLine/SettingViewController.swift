//
//  SettingViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/9/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    let ageGroupArray = ["Adult from 15 year","Child 12 - 15 year","Child 3 - 11 year","All"]
    let genderArray = ["Male","Female","Both"]
    var settingDic = [String:Bool]()
    var expandCollapseArrau = [false,false]
    var currentSelectedLanguage = 0
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.settingsTableView.estimatedRowHeight = 120
        self.settingsTableView.rowHeight = UITableViewAutomaticDimension
        self.loadSettingsdata()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSettingsdata()  {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "Adult from 15 year") is Bool
        {
            self.settingDic["Adult from 15 year"] = defaults.value(forKey: "Adult from 15 year") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Adult from 15 year")
            self.settingDic["Adult from 15 year"] = true
        }
        
        if defaults.value(forKey: "Child 12 - 15 year") is Bool
        {
            self.settingDic["Child 12 - 15 year"] = defaults.value(forKey: "Child 12 - 15 year") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Child 12 - 15 year")
            self.settingDic["Child 12 - 15 year"] = true
        }
        
        if defaults.value(forKey: "Child 3 - 11 year") is Bool
        {
            self.settingDic["Child 3 - 11 year"] = defaults.value(forKey: "Child 3 - 11 year") as? Bool
        }
        else
        {
            defaults.set(true, forKey: "Child 3 - 11 year")
            self.settingDic["Child 3 - 11 year"] = true
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
        if defaults.value(forKey: "CurrentSelectedLanguage") == nil
        {
            defaults.set(0, forKey: "CurrentSelectedLanguage")
        }
        else
        {
            self.currentSelectedLanguage = defaults.value(forKey: "CurrentSelectedLanguage") as! Int
        }
        
        self.settingsTableView.reloadData()
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
            if self.settingDic["Adult from 15 year"]!
            {
                ageGroup = "adult"
            }
            if self.settingDic["Child 12 - 15 year"]!
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
            
            if self.settingDic["Child 3 - 11 year"]!
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
        defaults.set(self.settingDic["Adult from 15 year"], forKey: "Adult from 15 year")
        defaults.set(self.settingDic["Child 12 - 15 year"], forKey: "Child 12 - 15 year")
        defaults.set(self.settingDic["Child 3 - 11 year"], forKey: "Child 3 - 11 year")
        defaults.set(self.settingDic["All"], forKey: "All")
        defaults.set(self.settingDic["Male"], forKey: "Male")
        defaults.set(self.settingDic["Female"], forKey: "Female")
        defaults.set(self.settingDic["Both"], forKey: "Both")
        defaults.set(self.currentSelectedLanguage, forKey: "CurrentSelectedLanguage")
        self.displayToast(alertMsg: "Settings saved.")
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
                return 3
            }
            else {
                return 1
            }
        default:
            if self.expandCollapseArrau[section] {
                return 2
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
            //cell.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            return cell
        }
        else
        {
            if indexPath.section == 0 {
                if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "messageFilterCell", for: indexPath) as! MessageFilterTableViewCell
                    cell.ageGroupCollectionView.tag = 1010
                    cell.ageGroupCollectionView.reloadData()
                    cell.ageGroupCollectionViewHeight.constant = cell.ageGroupCollectionView.collectionViewLayout.collectionViewContentSize.height
                    cell.ageGroupCollectionView.layoutIfNeeded()
                    cell.layoutIfNeeded()
                    self.settingsTableView.layoutIfNeeded()
                    cell.selectionStyle = .none
                    //cell.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "genderFilterCell", for: indexPath) as! GenderFilterTableViewCell
                    cell.genderCollectionView.tag = 1020
                    cell.genderCollectionView.reloadData()
                    cell.genderCollectionHeight.constant = cell.genderCollectionView.collectionViewLayout.collectionViewContentSize.height
                    cell.genderCollectionView.layoutIfNeeded()
                    cell.layoutIfNeeded()
                    self.settingsTableView.layoutIfNeeded()
                    cell.selectionStyle = .none
                    //cell.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                    return cell
                }
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "languageFilterCell", for: indexPath) as! LanguageFilterTableViewCell
                cell.languageCollectionView.tag = 1030
                cell.languageCollectionView.reloadData()
                cell.languageCollectionViewHeight.constant = cell.languageCollectionView.collectionViewLayout.collectionViewContentSize.height
                cell.languageCollectionView.layoutIfNeeded()
                cell.layoutIfNeeded()
                self.settingsTableView.layoutIfNeeded()
                cell.selectionStyle = .none
                //cell.backgroundColor = UIColor.white.withAlphaComponent(0.8)
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
            let sectionIndex = IndexSet(integer: indexPath.section)
            tableView.reloadSections(sectionIndex, with: .automatic)
            let indexPath = IndexPath.init(row: 0, section: indexPath.section)
            tableView.scrollToRow(at: indexPath as IndexPath, at: .middle, animated: true)
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
            let fullString = self.ageGroupArray[indexPath.row]
            let splittedStringsArray = fullString.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            cell.ageTitleLabel.text = String(describing: splittedStringsArray.first!)
            
            if splittedStringsArray.count > 1
            {
                cell.ageDescriptionLabel.text = String(describing: splittedStringsArray.last!)
            }
            else
            {
                cell.ageDescriptionLabel.text = nil
            }
            cell.ageGroupImageView.image = UIImage.init(named: self.ageGroupArray[indexPath.row])
            if self.settingDic[self.ageGroupArray[indexPath.row]]!
            {
                cell.selectionImageView.isHidden = false
                let color = UIColor(red: 159.0/255, green: 206.0/255, blue: 255.0/255, alpha: 1.0)
                cell.layer.borderColor = color.cgColor
            }
            else
            {
                cell.selectionImageView.isHidden = true
                let color = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
                cell.layer.borderColor = color.cgColor
            }
            
            if indexPath.row == 3 {
                cell.ageDescriptionLabelHeight.constant = 0
            }
            else {
                cell.ageDescriptionLabelHeight.constant = 15
            }
            cell.backgroundColor = UIColor.white
            return cell
        }
        else if collectionView.tag == 1020 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genderCollectionCell", for: indexPath) as! GenderGroupCollectionViewCell
            
            let fullString = self.genderArray[indexPath.row]
            let splittedStringsArray = fullString.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            cell.genderNameTitleLabel.text = String(describing: splittedStringsArray.first!)
            cell.genderImageView.image = UIImage.init(named: self.genderArray[indexPath.row])
            if self.settingDic[self.genderArray[indexPath.row]]!
            {
                cell.selectionImageView.isHidden = false
                let color = UIColor(red: 159.0/255, green: 206.0/255, blue: 255.0/255, alpha: 1.0)
                cell.layer.borderColor = color.cgColor
            }
            else
            {
                cell.selectionImageView.isHidden = true
                let color = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
                cell.layer.borderColor = color.cgColor
            }
            cell.backgroundColor = UIColor.white
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "languageCollectionCell", for: indexPath) as! LanguageGroupCollectionViewCell
            switch indexPath.row {
            case 0:
                cell.languageName.text = "English"
                cell.languageImageView.image = UIImage.init(named: "UK Flag")
            case 1:
                cell.languageName.text = "German"
                cell.languageImageView.image = UIImage.init(named: "German Flag")
            case 2:
                cell.languageName.text = "Faroese"
                cell.languageImageView.image = UIImage.init(named: "Farose Flag")
            default:
                cell.languageName.text = "Danish"
                cell.languageImageView.image = UIImage.init(named: "Danish flag")
            }
            
            if indexPath.row == self.currentSelectedLanguage {
                cell.selectionImageView.isHidden = false
                let color = UIColor(red: 159.0/255, green: 206.0/255, blue: 255.0/255, alpha: 1.0)
                cell.layer.borderColor = color.cgColor
            }
            else
            {
                cell.selectionImageView.isHidden = true
                let color = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
                cell.layer.borderColor = color.cgColor
            }
            cell.backgroundColor = UIColor.white
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView.tag == 1010
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
        else if collectionView.tag == 1030
        {
            self.currentSelectedLanguage = indexPath.row
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
        collectionView.reloadData()
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
//        if collectionView.tag == 1010 {
//            return CGSize(width: 95, height: 128)
//        }
//        else if collectionView.tag == 1020 {
//            return CGSize(width: 95, height: 128)
//        }
//        else {
//            return CGSize(width: 95, height: 128)
//        }
        
        let deviceType = UIDevice.current.deviceType
        switch deviceType {
        case .iPhone5,.iPhone5S,.iPhone5C,.iPhoneSE:
            return CGSize(width: 100, height: 128)
        case .iPhone8Plus,.iPhone7Plus,.iPhone6SPlus,.iPhone6Plus:
            return CGSize(width: 100, height: 128)
        case .iPhone8,.iPhone7,.iPhone6S,.iPhone6:
            return CGSize(width: 100, height: 128)
        case .iPhoneX:
            return CGSize(width: 110, height: 128)
        case .iPhone4S, .iPhone4:
            return CGSize(width: 90, height: 128)
        default:
            return CGSize(width: 100, height: 128)
        }
        
    }

}