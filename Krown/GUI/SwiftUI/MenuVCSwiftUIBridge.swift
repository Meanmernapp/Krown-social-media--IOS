////
////  MenuVCSwiftUIBridge.swift
////  Krown
////
////  Created by Ivan Kodrnja on 18.09.2021..
////  Copyright © 2021 KrownUnity. All rights reserved.
////
//
//import SwiftUI
//import UIKit
//
//struct MenuVCSwiftUIBridge: UIViewControllerRepresentable {
//
//    func makeUIViewController(context: Context) -> MenuVC {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//            guard let menuVC = storyboard.instantiateViewController(
//                    identifier: "MenuVC") as? MenuVC else {
//                fatalError("Cannot load from storyboard")
//            }
//        return menuVC
//    }
//    func updateUIViewController(_ uiViewController: MenuVC, context: Context) {
//        
//    }
// 
//    
//}
