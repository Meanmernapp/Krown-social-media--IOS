//
//  MatchVCSwiftUIBridge.swift
//  Krown
//
//  Created by macOS on 25/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct MatchVCSwiftUIBridge: UIViewControllerRepresentable {
    
    var matchObject: MatchObject = MatchObject()

    func makeUIViewController(context: Context) -> MatchVC {
        //print("IS MatchVCSwiftUIBridge LOAD")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard let matchVC = storyboard.instantiateViewController(
                    identifier: "MatchVC") as? MatchVC else {
                fatalError("Cannot load from storyboard")
            }
        matchVC.isFromGoing = true
        matchVC.isPresented = true
        matchVC.match = matchObject
        return matchVC
    }
    
    func updateUIViewController(_ uiViewController: MatchVC, context: Context) {
        
    }


}
