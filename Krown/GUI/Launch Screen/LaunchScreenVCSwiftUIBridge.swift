//
//  LNewViewController.swift
//  Krown
//
//  Created by Akshay Devkate on 16/11/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI

class LaunchScreenVCSwiftUIBridge: UIViewController {
    
    @IBOutlet var theContainer: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let childView = UIHostingController(rootView: LaunchScreenSwiftUI())
        addChild(childView)
        childView.view.frame = theContainer.bounds
        
        theContainer.addSubview(childView.view)
      
    }
    


}
