//
//  MyProfileSwiftUIBridge.swift
//  Krown
//
//  Created by HaiDer's Macbook Pro on 24/01/2023.
//  Copyright © 2023 KrownUnity. All rights reserved.
//

import Foundation
import SwiftUI

struct MyProfileSwiftUIBridge: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MyProfileViewController {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)

            guard let myProfileVC = storyboard.instantiateViewController(
                    identifier: "MyProfileViewController") as? MyProfileViewController else {
                fatalError("Cannot load from storyboard")
            }
      
        return myProfileVC
    }
    
    func updateUIViewController(_ uiViewController: MyProfileViewController, context: Context) {
        
    }

    
}
