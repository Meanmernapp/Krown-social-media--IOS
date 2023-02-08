//
//  ScopeVCSwiftUIBridge.swift
//  Krown
//
//  Created by Ivan Kodrnja on 02.11.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI

struct ScopeVCSwiftUIBridge: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ScopeVC {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)

            guard let scopeVC = storyboard.instantiateViewController(
                    identifier: "ScopeVC") as? ScopeVC else {
                fatalError("Cannot load from storyboard")
            }
      
        return scopeVC
    }
    
    func updateUIViewController(_ uiViewController: ScopeVC, context: Context) {
        
    }

}

