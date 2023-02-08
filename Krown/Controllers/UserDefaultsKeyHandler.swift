//
//  UserDefaultsKeyHandler.swift
//  Krown
//
//  Created by Anders Teglgaard on 03/08/2022.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
struct UserDefaultsKeyHandler {
    struct User {
        static let deviceToken = "deviceToken"
    }
    
    struct Login {
        static let fb_full = "fb_full"
        static let fb_limited = "fb_limited"
        static let userLogin = "userLogin"
        static let countOfDiscoverPeopleAccesses = "countOfDiscoverPeopleAccesses"
        static let hasClickWaveBefore = "hasClickWaveBefore"
    }
}
