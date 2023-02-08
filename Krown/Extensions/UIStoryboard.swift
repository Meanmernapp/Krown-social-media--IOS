//
//  UIStoryboard+Loader.swift
//  MVVMExample
//
//  Created by Dino Bartosak on 18/09/16.
//  Copyright © 2016 Toptal. All rights reserved.
//

import UIKit

typealias AppStoryboard = UIStoryboard

private enum Storyboard: String {
    case main = "Main"
    case profile = "Profile"
    case events = "Events"
    case chat = "Chat"
}

fileprivate extension AppStoryboard {

    static func loadFromStoryboard(_ type: Storyboard, identifier: String) -> UIViewController {
        return load(from: type, identifier: identifier)
    }
    // add convenience methods for other storyboards here ...

    // ... or use the main loading method directly when instantiating view controller
    // from a specific storyboard
    static func load(from storyboard: Storyboard, identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        return uiStoryboard.instantiateViewController(withIdentifier: identifier)
    }
}

// MARK: App View Controllers
// MARK: Public

extension AppStoryboard {

    // MARK: - Manage 'Main' Storyboard ViewControllers

//    static func loadLoginVC() -> LoginVC {
//        return loadFromStoryboard(.main, identifier: "LoginVC") as! LoginVC
//    }

    static func loadLoginInfoVC() -> LoginInfoVC {
        return loadFromStoryboard(.main, identifier: "LoginInfoVC") as! LoginInfoVC
    }

//    static func loadMenuVC() -> MenuVC {
//        return loadFromStoryboard(.main, identifier: "MenuVC") as! MenuVC
//    }

    static func loadHomeVC() -> HomeVC {
        return loadFromStoryboard(.main, identifier: "HomeVC") as! HomeVC
    }

    static func loadMatchVC() -> MatchVC {
        return loadFromStoryboard(.main, identifier: "MatchVC") as! MatchVC
    }

    static func noInternetVC() -> NoInternetVC {
        return loadFromStoryboard(.main, identifier: "NoInternetVC") as! NoInternetVC
    }

    //MARK:- Event Storyboard
    static func loadEventsVC() -> HomeVC {
        return loadFromStoryboard(.main, identifier: "HomeVC") as! HomeVC
    }
    
    // MARK: - Manage 'Profile' Storyboard ViewControllers

//    static func loadPreferencesVC() -> PreferencesVC {
//        return loadFromStoryboard(.profile, identifier: "PreferencesVC") as! PreferencesVC
//    }
    static func loadSettingsVC() -> SettingsVC {
        return loadFromStoryboard(.profile, identifier: "SettingsVC") as! SettingsVC
    }

    static func loadScopeVC() -> ScopeVC {
        return loadFromStoryboard(.profile, identifier: "ScopeVC") as! ScopeVC
    }

    static func loadEditProfileVC() -> EditProfileVC {
        return loadFromStoryboard(.profile, identifier: "EditProfileVC") as! EditProfileVC
    }

    static func loadTakeVideoVC() -> takeVideoVC {
        return loadFromStoryboard(.profile, identifier: "takeVideoVC") as! takeVideoVC
    }

    static func loadWebVC() -> WebVC {
        return loadFromStoryboard(.profile, identifier: "WebVC") as! WebVC
    }

    static func loadHeatMapVC() -> HeatMapVC {
        return loadFromStoryboard(.profile, identifier: "HeatMapVC") as! HeatMapVC
    }

    static func loadShareVC() -> ShareVC {
        return loadFromStoryboard(.profile, identifier: "ShareVC") as! ShareVC
    }
    
    static func loadMyProfileVC() -> MyProfileViewController {
        return loadFromStoryboard(.profile, identifier: "MyProfileViewController") as! MyProfileViewController
    }

    // MARK: - Manage 'Events' Storyboard ViewControllers

    static func loadSuggestedEventVC() -> popOverSuggestedEvent {
        return loadFromStoryboard(.events, identifier: "popOverSuggestedEvent") as! popOverSuggestedEvent
    }

    static func loadMenuSuggestedEventCard() -> MenuSuggestedEventCard {
        return loadFromStoryboard(.events, identifier: "KolodaSuggestedEventView") as! MenuSuggestedEventCard
    }

}
