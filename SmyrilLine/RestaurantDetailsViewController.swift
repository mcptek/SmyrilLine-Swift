//
//  RestaurantDetailsViewController.swift
//  SmyrilLine
//
//  Created by Rafay Hasan on 11/1/17.
//  Copyright © 2017 Rafay Hasan. All rights reserved.
//

import UIKit

class RestaurantDetailsViewController: UIViewController {

    var restaurantDetailsObject: RestaurantDetailsInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain, target: nil, action: nil)
        self.title = self.restaurantDetailsObject?.name
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

}
