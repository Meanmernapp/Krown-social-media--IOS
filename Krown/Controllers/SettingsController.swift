//
//  SettingsController.swift
//  Krown
//
//  Created by KrownUnity on 25/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
import UIKit

class SettingsController {

    static let shared = SettingsController()
    
    func getSettings(_ callback: @escaping (SettingsObject) -> Void) {
        WebServiceController.shared.getSettings() { (response) in
            //print(response)
            if let Settings : NSArray = response.object(forKey: "Settings") as? NSArray {
                if Settings.count > 0 {
                    if let dict : [String : Any] = Settings.object(at: 0) as? [String : Any] {
                        let settingsObj: SettingsObject = SettingsObject.init(dict)
                        callback(settingsObj)
                    }
                }
            }
        }
    }
    func updateSettings(_ dictParams: [String : AnyObject], callback: @escaping (String) -> Void) {
        WebServiceController.shared.updateSettings(dictParams) { (response) in
            //print(response)
            if let ErrorCode : String = response.object(forKey: "ErrorCode") as? String {
                callback(ErrorCode)
            }
        }
    }

    func update_phone_email(phone_number: String, email: String, callback: @escaping (String) -> Void) {
        WebServiceController.shared.update_phone_email(phone_number: phone_number, email: email) { (response) in
            //print(response)
            if let ErrorCode : String = response.object(forKey: "ErrorCode") as? String {
                callback(ErrorCode)
            }
        }
    }

    
}
