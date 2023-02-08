//
//  LoginInfoVC.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit

class LoginInfoVC: UIViewController {

    let loginController = LoginController()
    let mainController = MainController()

    @IBAction func loginBtn(_ sender: AnyObject) {
    }

    @IBAction func exitBtn(_ sender: AnyObject) {
       self.dismiss(animated: true, completion: nil)
    }

}
