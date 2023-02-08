////
////  PreferencesSwiftUIBridge.swift
////  Krown
////
////  Created by Ivan Kodrnja on 02.11.2021..
////  Copyright © 2021 KrownUnity. All rights reserved.
////
//
//import SwiftUI
//
//
//    struct PreferencesSwiftUIBridge: UIViewControllerRepresentable {
//        
//        func makeUIViewController(context: Context) -> PreferencesVC {
//            
//            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
//
//                guard let preferencesVC = storyboard.instantiateViewController(
//                        identifier: "PreferencesVC") as? PreferencesVC else {
//                    fatalError("Cannot load from storyboard")
//                }
//          
//            return preferencesVC
//        }
//        
//        func updateUIViewController(_ uiViewController: PreferencesVC, context: Context) {
//            
//        }
//
//        
//    }
//
