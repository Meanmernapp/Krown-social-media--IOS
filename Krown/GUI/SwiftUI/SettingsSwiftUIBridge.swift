//
//  SettingsSwiftUIBridge.swift
//  Krown
//
//  Created by macOS on 28/12/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI

struct SettingsSwiftUIBridge: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> SettingsVC {
        return AppStoryboard.loadSettingsVC()
    }
    
    func updateUIViewController(_ uiViewController: SettingsVC, context: Context) {
        
    }

}
