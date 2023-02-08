//
//  ChatListVCSwiftUIBridge.swift
//  Krown
//
//  Created by Ivan Kodrnja on 18.09.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI


struct MatchesChatVCSwiftUIBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MatchesChatVC {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)

            guard let chatListVC = storyboard.instantiateViewController(
                    identifier: "MatchesChatVC") as? MatchesChatVC else {
                fatalError("Cannot load from storyboard")
            }
        return chatListVC
    }

    func updateUIViewController(_ uiViewController: MatchesChatVC, context: Context) {
        
    }
}
