//
//  FeedbackSwiftUIBridge.swift
//  Krown
//
//  Created by Mac Mini 2020 on 17/05/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI


    struct FeedbackSwiftUIBridge: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> FeedbackVC {
            
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)

                guard let feedbackVC = storyboard.instantiateViewController(
                        identifier: "FeedbackVC") as? FeedbackVC else {
                    fatalError("Cannot load from storyboard")
                }
          
            return feedbackVC
        }
        
        func updateUIViewController(_ uiViewController: FeedbackVC, context: Context) {
            
        }

        
    }


