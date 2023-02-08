//
//  ProfilePreviewSwiftUIBridge.swift
//  Krown
//
//  Created by Mac Mini 2020 on 14/04/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct ProfilePreviewSwiftUIBridge: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ProfilePreviewVC {
        //print("IS HomeVCSwiftUIBridge LOAD")
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)

            guard let profilePreviewVC = storyboard.instantiateViewController(
                    identifier: "ProfilePreviewVC") as? ProfilePreviewVC else {
                fatalError("Cannot load from storyboard")
            }
        return profilePreviewVC
    }
    
    func updateUIViewController(_ uiViewController: ProfilePreviewVC, context: Context) {
        
    }
}

