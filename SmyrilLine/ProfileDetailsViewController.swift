//
//  ProfileDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/30/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import Photos
import AlamofireObjectMapper
import Alamofire
import SwiftyJSON
import SDWebImage

class ProfileDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var picButton: UIButton!
    @IBOutlet weak var profileDetailsTableview: UITableView!
    var base64Data: String?
    var activityIndicatorView: UIActivityIndicatorView!
    var selectedImage = UIImage()
    var gender: String?
    var language: String?
    var ticket: String?
    var username: String?
    var introInfo: String?
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imagePicker.delegate = self
        self.checkPhotoLibraryPermission()
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        self.activityIndicatorView = myActivityIndicator
        view.addSubview(self.activityIndicatorView)
        
        self.picButton.layer.cornerRadius = self.picButton.frame.size.height / 2
        self.picImageView.layer.cornerRadius = self.picImageView.frame.size.height / 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUserDetailsData()
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
        
        if segue.identifier == "editUserProfileData" {
            let row = (sender as! NSIndexPath).row
            let navVC = segue.destination as? UINavigationController
            let vc = navVC?.viewControllers.first as! EditProfileViewController
            if row == 0 {
                vc.headerStr = "Set user name"
            }
            else {
                vc.headerStr = "Set intro info"
            }
        }
    }
    
    
    func setUserDetailsData()  {
        self.language = "English"
        self.gender = "Male"
        self.ticket = "123456"
        if ((UserDefaults.standard.value(forKey: "userName") as? String) != nil) {
            self.username = (UserDefaults.standard.value(forKey: "userName") as! String)
        }
        else {
            self.username = "Add text"
        }
        
        if ((UserDefaults.standard.value(forKey: "introInfo") as? String) != nil) {
            self.introInfo = (UserDefaults.standard.value(forKey: "introInfo") as! String)
        }
        else {
            self.introInfo = "Add text"
        }
        
        if let imageUrlStr = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String {
            self.picImageView.sd_setShowActivityIndicatorView(true)
            self.picImageView.sd_setIndicatorStyle(.gray)
            self.picImageView.sd_setImage(with: URL(string: imageUrlStr), placeholderImage: UIImage.init(named: ""))
        }
        
        self.profileDetailsTableview.reloadData()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.uploadProfilePic()
    }
    
    @IBAction func pictureButtonAction(_ sender: Any) {
        let alertViewController = UIAlertController(title: "", message: "Choose your option", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (alert) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func retrieveUserProfileDetails() -> [String: Any] {
        
        if (self.selectedImage.hasContent) {
            let initialBase64Data = self.selectedImage.convertToBase64(image: selectedImage)
            self.base64Data = "data:image/png;base64,"+initialBase64Data
        }
        
        var imageUrl = String()
        if let url = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String {
            imageUrl = url
            if self.base64Data != nil {
                imageUrl = ""
            }
        }
        else {
            imageUrl = ""
        }
        
        var userName = ""
        if let profileUserName = UserDefaults.standard.value(forKey: "userName") as? String {
            userName = profileUserName
        }
        else {
            userName = ""
        }
        
        var introInfo = ""
        if let profileUserIntroInfo = UserDefaults.standard.value(forKey: "introInfo") as? String {
            introInfo = profileUserIntroInfo
        }
        else {
            introInfo = ""
        }
        
        var visibilityStatus = 2
        if let status = UserDefaults.standard.value(forKey: "userVisibilityStatus") as? String {
            if status == "Visible to boking" {
                visibilityStatus = 1
            }
            else if status == "Invisible" {
                visibilityStatus = 3
            }
        }
        
        let bookingNumber = 123456
        let status = 1
        
        
        let params: Parameters = [
            "bookingNo": bookingNumber,
            "Name": userName,
            "description": introInfo,
            "imageUrl": imageUrl,
            "country": "Bangladesh",
            "deviceId": (UIDevice.current.identifierForVendor?.uuidString)!,
            "gender": "Male",
            "status": status,
            "visibility": visibilityStatus,
            "imageBase64": self.base64Data ?? "",
            "phoneType": "iOS",
        ]
        return params
    }
    
    func uploadProfilePic()  {
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        let url = UrlMCP.server_base_url + UrlMCP.WebSocketProfilePicImageUpload
        
        Alamofire.request(url, method:.post, parameters:self.retrieveUserProfileDetails(), headers:nil).responseObject { (response: DataResponse<UserProfile>) in
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success:
                if let url = response.result.value?.imageUrl {
                    UserDefaults.standard.set(url, forKey: "userProfileImageUrl")
                }
                else {
                    print("Image upload failed")
                }
                self.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                print(error)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Hi..")
        //handle authorized status
        case .denied, .restricted :
        //handle denied status
            print("Hi..")
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    print("Hi..")
                // as above
                case .denied, .restricted:
                // as above
                    print("Hi..")
                case .notDetermined:
                    // won't happen but still
                    print("Hi..")
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userDetailsCell", for: indexPath) as! UserDetailsInfoTableViewCell
        switch indexPath.row {
        case 0:
            cell.headerLabel.text = "User name"
            cell.valuelabel.text = self.username
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.headerLabel.text = "Intro info"
            cell.valuelabel.text = self.introInfo
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.headerLabel.text = "Gender"
            cell.valuelabel.text = self.gender
            cell.accessoryType = .none
        case 3:
            cell.headerLabel.text = "Language"
            cell.valuelabel.text = self.language
            cell.accessoryType = .none
        case 4:
            cell.headerLabel.text = "Ticket"
            cell.valuelabel.text = self.ticket
            cell.accessoryType = .none
        default:
            cell.headerLabel.text = nil
            cell.valuelabel.text = nil
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 || indexPath.row == 1 {
            self.performSegue(withIdentifier: "editUserProfileData", sender: indexPath)
        }
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
    func takeProfilePic()  {
        print("Button clicke")
        let alertViewController = UIAlertController(title: "", message: "Choose your option", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (alert) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.modalPresentationStyle = .overCurrentContext
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        else {
            //let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            //alertWarning.show()
        }
    }
    
    func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.modalPresentationStyle = .overCurrentContext
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth,height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //# MARK: - UIImagePickerController Delegate and DataSource Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage  {
            self.selectedImage = resizeImage(image: image, newWidth: 128)
            //self.picButton?.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            self.picImageView.image = self.selectedImage
            self.picImageView.layer.cornerRadius = self.picImageView.frame.size.height / 2
            self.picButton.imageView?.layer.cornerRadius = self.picButton.frame.size.height / 2
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        dismiss(animated: true, completion: nil)
    }
    
}
