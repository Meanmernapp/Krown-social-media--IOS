//
//  HeatMapVC.swift
//  Krown
//
//  Created by KrownUnity on 21/12/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import CoreGraphics
import Alamofire


class HeatMapVC: UIViewController {

  //  @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var dayChanger: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageBorder: UIColor = UIColor.black

        let placeholderImage = UIImage(named: "man.jpg")!
        let url = URL(string: (UserDefaults.standard.object(forKey: WebKeyhandler.User.profilePic)! as! NSArray)[0] as! String)
        //Add authentication header
        var imageUrlRequest = URLRequest(url: url!)
        var headers: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            headers = [.authorization(bearerToken: "ForceRefresh"),]
        }
        imageUrlRequest.headers = headers
        profilePic.af.setImage(withURLRequest: imageUrlRequest, placeholderImage: placeholderImage)
        profilePic.layer.masksToBounds = false
        profilePic.layer.cornerRadius = profilePic.frame.width/2
        profilePic.layer.borderWidth = 6.0
        profilePic.layer.borderColor = imageBorder.cgColor
        profilePic.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
