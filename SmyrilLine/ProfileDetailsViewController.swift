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


class ProfileDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var picButton: UIButton!
    @IBOutlet weak var profileDetailsTableview: UITableView!
    var base64Data = String()
    var activityIndicatorView: UIActivityIndicatorView!
    var selectedImage = UIImage()
    
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
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.uploadProfilePic()
        //self.uploadImage()
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
        if let url = UserDefaults.standard.value(forKey: "UserProfilePicUrl") as? String {
            imageUrl = url
        }
        else {
            imageUrl = ""
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
            "Name": "Rafay",
            "description": "Test description",
            "imageUrl": imageUrl,
            "country": "Bangladesh",
            "deviceId": (UIDevice.current.identifierForVendor?.uuidString)!,
            "gender": "Male",
            "status": status,
            "visibility": visibilityStatus,
            "imageBase64": self.base64Data,
            "phoneType": "iOS",
        ]
        return params
    }
    
    func uploadProfilePic()  {
        
        let url = "http://192.168.1.47:5000/chat/api/v2/profileupdate"
        
        Alamofire.request(url, method:.post, parameters:self.retrieveUserProfileDetails(), headers:nil).responseJSON { response in
            switch response.result {
            case .success:
                debugPrint(response)
                
            case .failure(let error):
                print(error)
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
            cell.valuelabel.text = "Add text"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.headerLabel.text = "Intro info"
            cell.valuelabel.text = "Add text"
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.headerLabel.text = "Gender"
            cell.valuelabel.text = "Male"
            cell.accessoryType = .none
        case 3:
            cell.headerLabel.text = "Language"
            cell.valuelabel.text = "English"
            cell.accessoryType = .none
        case 4:
            cell.headerLabel.text = "Ticket"
            cell.valuelabel.text = "123456789"
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
            self.performSegue(withIdentifier: "editUserProfileData", sender: self)
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
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.imagePicker.allowsEditing = false
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
            self.imagePicker.allowsEditing = false
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
            self.picButton?.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
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
