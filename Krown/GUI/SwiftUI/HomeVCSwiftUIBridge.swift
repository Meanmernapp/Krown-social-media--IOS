//
//  HomeVCSwiftUIBridge.swift
//  Krown
//
//  Created by Ivan Kodrnja on 18.09.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI

struct HomeVCSwiftUIBridge: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> HomeVC {
        //print("IS HomeVCSwiftUIBridge LOAD")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard let homeVC = storyboard.instantiateViewController(
                    identifier: "HomeVC") as? HomeVC else {
                fatalError("Cannot load from storyboard")
            }
        return homeVC
    }
    
    func updateUIViewController(_ uiViewController: HomeVC, context: Context) {
        
    }


}
