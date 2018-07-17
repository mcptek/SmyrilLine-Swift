//
//  MySmyrilLineViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/1/18.
//  Copyright © 2018 Rafay Hasan. All rights reserved.
//

import UIKit

class MySmyrilLineViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var bookingSegmentControl: UISegmentedControl!
    @IBOutlet weak var bookingTableview: UITableView!
    var bookingData: [String: Any]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let movies = ["Batman","Batman","Flash","Avengers"]
        var movieCounts:[String:Int] = [:]
        for movie in movies {
            movieCounts[movie] = (movieCounts[movie] ?? 0) + 1
        }
        for (key, value) in movieCounts {
            print("\(key) has been selected \(value) time/s")
        }
        print(self.bookingData ?? "Default value")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
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

    @IBAction func segmentControlButtonAction(_ sender: Any) {
        self.bookingTableview.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.bookingSegmentControl.selectedSegmentIndex == 0 {
            return 5
        }
        else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.bookingSegmentControl.selectedSegmentIndex == 0 {
            if indexPath.section == 0 || indexPath.section == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "basicInfo", for: indexPath) as! BasicInfoTableViewCell
                if indexPath.section == 0 {
                    cell.infoImageView.image = UIImage.init(named: "bookingIcon")
                    cell.infoHeaderLabel.text = NSLocalizedString("Booking No", comment: "")
                    if let bookingNo = self.bookingData!["Bookno"] as? String {
                        cell.infoDetailsLabel.text = bookingNo
                    }
                    else {
                        cell.infoDetailsLabel.text = "-"
                    }
                }
                else {
                    cell.infoImageView.image = UIImage.init(named: "carIcon")
                    cell.infoHeaderLabel.text = NSLocalizedString("CAR", comment: "")
                    if let carInfo = self.bookingData!["TypeOfCar"] as? String {
                        cell.infoDetailsLabel.text = carInfo
                    }
                    else {
                        cell.infoDetailsLabel.text = "-"
                    }
                }
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileInfoTableViewCell
                cell.profileCollectionView.tag = 1000
                cell.profileCollectionView.reloadData()
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "travelersCell", for: indexPath) as! TravelersTableViewCell
                if let adult = self.bookingData!["NoOfAdults"] as? String {
                    cell.adultLabel.text = "Adult " + adult
                }
                else {
                    cell.adultLabel.text = "-"
                }
                
                if let child12 = self.bookingData!["NoOfChild12"] as? String, let child15 = self.bookingData!["NoOfChild15"] as? String {
                    let total = Int(child12)! + Int(child15)!
                    cell.childrenLabel.text = "| Child " + String(total)
                }
                else {
                    cell.childrenLabel.text = "-"
                }
                
                if let infant = self.bookingData!["NoOfInfants"] as? String {
                    cell.infantLabel.text = "| Infant " + infant
                }
                else {
                    cell.infantLabel.text = "-"
                }
                
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor.white
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as! RouteTableViewCell
                cell.routeCollectionview.tag = 2000
                cell.routeCollectionview.reloadData()
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! MealTableViewCell
            cell.backgroundColor = UIColor.white
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 1.0
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
            if let passengerArray = self.bookingData!["Passengers"] as? [Any] {
                return passengerArray.count
            }
            else {
                return 0
            }
        }
        else {
            if let routeArray = self.bookingData!["ListOfRoutes"] as? [Any] {
                return routeArray.count
            }
            else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView.tag == 1000 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCollectionViewCell
             if let passengerArray = self.bookingData!["Passengers"] as? [Any] {
                if let dic = passengerArray[indexPath.row] as? [String: Any] {
                    if let passengerName = dic["Name"] as? String {
                        cell.passengernameLabel.text = passengerName
                    }
                    else {
                        cell.passengernameLabel.text = "-"
                    }
                    
                    if let passengerSex = dic["Sex"] as? String {
                        if passengerSex == "M" {
                            cell.passengerSexLabel.text = "Male"
                        }
                        else {
                            cell.passengerSexLabel.text = "Female"
                        }
                    }
                    else {
                        cell.passengerSexLabel.text = "-"
                    }
                    
                    if let birthDate = dic["DateOfBirth"] as? String {
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd"
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "dd MMM yyyy"
                        
                        if let date = dateFormatterGet.date(from: birthDate){
                            cell.passengerDateOfBirthLabel.text = dateFormatterPrint.string(from: date)
                        }
                    }
                    else {
                        cell.passengerDateOfBirthLabel.text = "-"
                    }
                    
                    if let passengerNationality = dic["Nationality"] as? String {
                        cell.passengerNationalirtLabel.text = passengerNationality
                    }
                    else {
                        cell.passengerNationalirtLabel.text = "-"
                    }
                }
                
            }
            cell.backgroundColor = UIColor.white
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeCell", for: indexPath) as! RouteCollectionViewCell
            if let routeArray = self.bookingData!["ListOfRoutes"] as? [Any] {
                if let dic = routeArray[indexPath.row] as? [String: Any] {
                    if let departureName = dic["DepHarbor"] as? String {
                        cell.departureNameLabel.text = departureName
                    }
                    else {
                        cell.departureNameLabel.text = "-"
                    }
                    
                    if let departureDate = dic["DepDate"] as? String {
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "dd-MM-yyyy - HH:mm"
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "MMM dd (EEE), yyyy hh:mm a"
                        
                        if let date = dateFormatterGet.date(from: departureDate){
                            cell.departureTimaLabel.text = dateFormatterPrint.string(from: date)
                        }
                    }
                    else {
                        cell.departureTimaLabel.text = "-"
                    }
                    
                    if let arrivalName = dic["ArrHarbor"] as? String {
                        cell.arrivalNameLabel.text = arrivalName
                    }
                    else {
                        cell.arrivalNameLabel.text = "-"
                    }
                    
                    if let arrivalDate = dic["ArrDate"] as? String {
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "dd.MM.yyyy - HH:mm"
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "MMM dd (EEE), yyyy hh:mm a"
                        
                        if let date = dateFormatterGet.date(from: arrivalDate){
                            cell.arrivalTimeLabel.text = dateFormatterPrint.string(from: date)
                        }
                    }
                    else {
                        cell.arrivalTimeLabel.text = "-"
                    }
                }
            }
            cell.backgroundColor = UIColor.white
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)
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
             return CGSize(width: 315, height: 150)
        }
        else {
             return CGSize(width: 315, height: 143)
        }
    }
    
}
