//
//  AuthManager.swift
//  Krown
//
//  Created by Gurpreet Singh on 22/01/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import SwiftUI

class AuthManager: NSObject {

    static let shared = AuthManager()
    private override init() {}
    
    func setInitialScreen(_ window: UIWindow) {
        //If user has logged in with fb_full (AccessToken) or fb_limited (AuthenticationToken) then automatically log in.
        if (UserDefaults.standard.object(forKey: UserDefaultsKeyHandler.Login.userLogin)) != nil &&
            AccessToken.current != nil || (UserDefaults.standard.object(forKey: UserDefaultsKeyHandler.Login.userLogin)) != nil && AuthenticationToken.current != nil {
            setHomepage(window)
        } else {
            setLoginPage(window)
            
        }
    }

    func setHomepage(_ window: UIWindow) {
        
            //call the new SwiftUI view controller that handels tab bar
        Log.log(message: "HomeTabBarVC call 1 %@", type: .debug, category: Category.notifications, content: "")

            let swiftUIView = HomeTabBarVC().environmentObject(WebServiceController.shared)
            let hostingController = UIHostingController(rootView: swiftUIView)
            window.rootViewController = hostingController
            window.makeKeyAndVisible()
            
        MainController.shared.updateLoginInfo()
    }
   
    func setLoginPage(_ window: UIWindow) {
            let loginView = LoginView().environmentObject(WebServiceController.shared)
            let loginHostingController = UIHostingController(rootView: loginView)
            window.rootViewController = loginHostingController
            window.makeKeyAndVisible()
    }

}
