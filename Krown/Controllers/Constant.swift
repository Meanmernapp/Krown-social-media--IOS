//
//  Constant.swift
//  Krown
//
//  Created by Apple on 28/09/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
import SwiftEntryKit
import UIKit
import CoreLocation

enum viewtype {
    case goingView
    case matchesGoingView
    case waveView
    case nearbyView
}

enum checkSelectedMessageTypeFromMatch
{
    case text
    case image
    case location
    case paperClip
}


struct globalConstant{
    static var eventIDFromDeepLink : String = String()
    static var isUserAtLiveLocation = false
    static var isToolbarVisible = false
    static var POI = ""
    static var strUserLiveLocationName = ""
    static var arrMatchesId = [String]()
    static var personObject = PersonObject()
//    static var loginVC = LoginVC()
    static var isSwipeWave = false
    static var isHomeLoad = false
    static var currentLocation: CLLocation?
    static var isDissmiss = Bool()
    static var isFlagSwipeAction = Bool()
    static var isPreviewScreen  = Bool()
    static var allowShowingDiscoverNearby = false
}


func setWaveUsedUp(wave : [String:Any]){
    if (((wave["WavesUsed"] as? NSString)?.boolValue) == true) {
        UserDefaults.standard.set(true, forKey: WebKeyhandler.User.isWaveUsedUp)
        let waveResetTime = wave["WavesResetAt"] as? String ?? ""
        UserDefaults.standard.set(waveResetTime, forKey: WebKeyhandler.User.waveResetAt)
        
    }
    else{
        UserDefaults.standard.set(false, forKey: WebKeyhandler.User.isWaveUsedUp)
        UserDefaults.standard.set("", forKey: WebKeyhandler.User.waveResetAt)
    }
    UserDefaults.standard.synchronize()
}

func showWaveUsedUpPopUp(viewController : UIViewController, callback : @escaping ((Bool) -> ())){
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    let time1 = Date()
    let time2 = formatter.date(from: UserDefaults.standard.string(forKey: WebKeyhandler.User.waveResetAt) ?? "")
    let diffSeconds =  time2!.timeIntervalSinceReferenceDate - time1.timeIntervalSinceReferenceDate
    if diffSeconds <= 0 {
        UserDefaults.standard.set(false, forKey: WebKeyhandler.User.isWaveUsedUp)
        UserDefaults.standard.synchronize()
        callback(true)
        return
    }
    
    
    
    if let time = UserDefaults.standard.string(forKey: WebKeyhandler.User.waveResetAt){
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time1 = Date()
        guard let time2 = formatter.date(from: time ) else { return }
        let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: time1, to: time2)
        let formattedString = String(format: "%02ld:%02ld:%02ld", difference.hour!, difference.minute!, difference.second!)
        
        
        let vc = WaveUsedPopUP()
        vc.time = formattedString
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        viewController.present(vc, animated: true)
    }
}
