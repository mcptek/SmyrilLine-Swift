//
//  ShiptrackerViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 8/24/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit
import Mapbox
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

class ShiptrackerViewController: UIViewController,MGLMapViewDelegate {

    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var shipInfoContainerView: UIView!
    @IBOutlet weak var shipInfoContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shipDetailsButton: UIButton!
    
    
    
    var mapView: MGLMapView!
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var trajectoryArray:[JSON]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let styleURL = NSURL(string: "http://smy-wp.mcp.com/osm/raster-v8.json")
        self.mapView = MGLMapView(frame: self.mapContainerView.bounds,
                                  styleURL: styleURL as URL?)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Set the map’s center coordinate and zoom level.
        self.mapView.setCenter(CLLocationCoordinate2D(latitude: 45.52954,
                                                      longitude: -122.72317),
                               zoomLevel: 14, animated: false)
        self.mapView.delegate = self
        self.mapView.attributionButton.isHidden = true
        self.mapView.logoView.isHidden = true
        self.mapView.isRotateEnabled = false
        view.addSubview(self.mapView)
        self.view.bringSubview(toFront: self.shipInfoContainerView)
        self.view.bringSubview(toFront: self.shipDetailsButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.createAPICallForFBLogIn()
        self.createApiCallForShipTrackerInfo()
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
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1.0
    }
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor(red: 38.0/255.0, green: 111.0/255.0, blue: 247.0/255.0, alpha: 1)
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "pisa")
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = UIImage(named: "ShipDirection")!
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: self.imageRotatedByDegrees(oldImage: image, deg: self.getDirection()), reuseIdentifier: "pisa")
        }
        
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func createApiCallForShipTrackerInfo() {
        request(UrlMCP.shiptrackerInfo, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    if let json = response.data {
                        //let data = JSON(data: json)
                        if response.response?.statusCode == 200
                        {
                            if let jsonArray = JSON(data: json).array
                            {
                                print(jsonArray)
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }

    
    func createAPICallForFBLogIn()  {
        
        request("https://console.mcp.com/mtrajectory.php?ship=22", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    if let json = response.data {
                        self.trajectoryArray = [JSON(data: json)]
                        //let data = JSON(data: json)
                        if response.response?.statusCode == 200
                        {
                            if let jsonArray = JSON(data: json).array
                            {
                                self.trajectoryArray = jsonArray
                                if (self.trajectoryArray?.count)! >= 2
                                {
                                    self.DrawPloyLine()
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    func DrawPloyLine()  {
        
        var coorDinates = [CLLocationCoordinate2D]()
        var coordinate: CLLocationCoordinate2D?
        for object in self.trajectoryArray!
        {
            
            let latitude = object["lat"].string
            let longlitude = object["lon"].string
            coordinate = CLLocationCoordinate2DMake(Double(latitude!)!, Double(longlitude!)!)
            coorDinates.append(coordinate!)
            print(object["time"])
        }
        
        let polyLine = MGLPolyline.init(coordinates: coorDinates, count: UInt(coorDinates.count))
        self.endCoordinate = coorDinates[coorDinates.count - 1]
        self.startCoordinate = coorDinates[coorDinates.count - 2]
        self.mapView.addAnnotation(polyLine)
        let pisa = MGLPointAnnotation()
        pisa.coordinate = coordinate!
        pisa.title = "Leaning Tower of Pisa"
        self.mapView.addAnnotation(pisa)
        self.mapView.setCenter(coordinate!, animated: true)
    }
    
    func getDirection() -> Double {
        let lat1 = (self.startCoordinate?.latitude)! * Double.pi / 180.0
        let lon1 = (self.startCoordinate?.longitude)! * Double.pi / 180.0
        let lat2 = (self.endCoordinate?.latitude)! * Double.pi / 180.0
        let lon2 = (self.endCoordinate?.longitude)! * Double.pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        return radiansBearing * 180.0 / Double.pi
        
    }
    
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: Double) -> UIImage {
        
        print(degrees,self.startCoordinate!,self.endCoordinate!)
        let size = oldImage.size
        UIGraphicsBeginImageContext(size)
        
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (CGFloat(degrees * (Double.pi / 180))))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        
        //let origin = CGPoint(x: -size.width / 2, y: -size.width / 2)
        
        //bitmap.draw(oldImage.cgImage!, in: CGRect(origin: origin, size: size))
        let rect = CGRect(origin: CGPoint(x: -oldImage.size.width / 2,  y: -oldImage.size.height / 2), size: oldImage.size)
        bitmap.draw(oldImage.cgImage!, in: rect)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    @IBAction func shipInfoButtonAction(_ sender: UIButton) {
        
        let image = UIImage.init(named: "ShipDetailsMinusIcon")
        if self.shipDetailsButton.backgroundImage(for: .normal) == image
        {
            self.shipDetailsButton.setBackgroundImage(UIImage.init(named: "ShipDetailsPlusIcon"), for: .normal)
            UIView.animate(withDuration: Double(0.7), animations: {
                self.shipInfoContainerViewHeightConstraint.constant = 153
                self.view.layoutIfNeeded()
            })
        }
        else
        {
            self.shipDetailsButton.setBackgroundImage(UIImage.init(named: "ShipDetailsMinusIcon"), for: .normal)
            UIView.animate(withDuration: Double(0.7), animations: {
                self.shipInfoContainerViewHeightConstraint.constant = 60
                self.view.layoutIfNeeded()
            })        }
    }

}
