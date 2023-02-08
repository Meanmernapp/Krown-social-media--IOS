//
//  CustomAlertSwiftUIBridge.swift
//  Krown
//
//  Created by macOS on 05/03/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct CustomAlertSwiftUIBridge: UIViewControllerRepresentable {
    
    var isEventFor: String = String()
    func makeUIViewController(context: Context) -> CustomAlertVC {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)

            guard let customAlertVC = storyboard.instantiateViewController(
                    identifier: "CustomAlertVC") as? CustomAlertVC else {
                fatalError("Cannot load from storyboard")
            }
        customAlertVC.modalPresentationStyle = .custom
        customAlertVC.transitioningDelegate = customAlertVC
        customAlertVC.strImgArr = [["value":"Not going" ,"action":"notGoing"],
                                   ["value":"Interested","action":"interested"],
                                   ["value":"Going"     ,"action":"attending"]]
        customAlertVC.isFromSwiftUI = true
      
        return customAlertVC
    }
    
    func updateUIViewController(_ uiViewController: CustomAlertVC, context: Context) {
        
    }

    
}
