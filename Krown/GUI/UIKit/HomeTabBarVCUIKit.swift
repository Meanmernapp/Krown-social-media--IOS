//
//  HomeTabBarVCUIKit.swift
//  Krown
//
//  Created by Ivan Kodrnja on 18.09.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI

class HomeTabBarVCUIKit: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("HomeTabBarVC Call 3")
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBar.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.isHidden = false
        // Create Tab one
        let swiftUIView = MyEvents()
        let hostingController = UIHostingController(rootView: swiftUIView)
        let tabOne = UINavigationController.init(rootViewController: hostingController)
        let tabOneBarItem = UITabBarItem(title: "", image: UIImage(named: "My Events"), selectedImage: UIImage(named: "My Events-1"))
        
        tabOne.tabBarItem = tabOneBarItem
        
        
        // Create Tab two
        let tabTwo = UINavigationController.init(rootViewController: HomeVC())
        let tabTwoBarItem = UITabBarItem(title: "", image: UIImage(named: "Discover"), selectedImage: UIImage(named: "Discover-1"))
        
        tabTwo.tabBarItem = tabTwoBarItem
        
        // Create Tab three
        let swiftUIView1 = MyEvents()//MatchesView()
        let hostingController1 = UIHostingController(rootView: swiftUIView1)
        let tabThree = UINavigationController.init(rootViewController: hostingController1)
        let tabThreeBarItem = UITabBarItem(title: "", image: UIImage(named: "Matches"), selectedImage: UIImage(named: "Matches-1"))
        
        tabThree.tabBarItem = tabThreeBarItem
        
        
        self.viewControllers = [tabOne, tabTwo, tabThree]
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //print("Selected \(viewController.title!)")
    }
}
