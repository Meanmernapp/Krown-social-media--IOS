//
//  MatchProfilePreviewSwiftUIBridge.swift
//  Krown
//
//  Created by Mac Mini 2020 on 17/05/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
import SwiftUI

struct MatchProfilePreviewSwiftUIBridge: UIViewControllerRepresentable {
    var matchObject = [MatchesModel]()
    var type : viewtype?
    var title = ""
    
    func makeUIViewController(context: Context) -> KolodaSwipeProfilesVC {
        //print("IS HomeVCSwiftUIBridge LOAD")
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)

            guard let matchProfilePreviewVC = storyboard.instantiateViewController(
                    identifier: "MatchProfilePreviewVC") as? KolodaSwipeProfilesVC else {
                fatalError("Cannot load from storyboard")
            }
        
        matchProfilePreviewVC.profileInfoMatchModel = matchObject
        matchProfilePreviewVC.mainProfileInfoMatchModel = matchObject
        PersonController().getListPeopleViewProfile(profileArray: matchObject){ profile in
            matchProfilePreviewVC.profileInfo = profile
        }
        matchProfilePreviewVC.viewType = type
        matchProfilePreviewVC.strTitle = title
        return matchProfilePreviewVC
    }
    
    func updateUIViewController(_ uiViewController: KolodaSwipeProfilesVC, context: Context) {
        
    }
}

