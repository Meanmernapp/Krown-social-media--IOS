//
//  UserController.swift
//  Krown
//
//  Created by KrownUnity on 26/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
import FBSDKCoreKit

enum Credentials: String {
    case fName = "first_name" //
    case lName = "last_name" //
    case email =  "email" //
    case id = "id" //
    case fbID = "fb_id"
    case gender = "gender"
    case birthday = "birthday" //
    case ageRange = "age_range" //
    case deviceType = "1"
    case pushToken = "deviceToken" //
    case accessToken
    case workPlace = "emplyer"
    case workPosition = "position"
    case schoolName = "school"
    case schoolConcentration = "concentration"
}

class UserController {
    static let shared = UserController()
    func setUserToUserDefault(facebookUserInfo: NSDictionary, mainController: MainController) {
        UserDefaults.standard.set(URLHandler.userPreFix + String(describing: facebookUserInfo.object(forKey: WebKeyhandler.User.userID)!) + URLHandler.xmpp_domainResource, forKey: UserDefaultsKeyHandler.Login.userLogin)
        UserDefaults.standard.set("123456", forKey: "userPassword")
        UserDefaults.standard.synchronize()
    }
    
    func parseFacebookUserInfo(_ facebookUserInfo: NSDictionary, mainController: MainController, callback : @escaping (NSDictionary) -> Void) {
        
        
        let userInfo = NSMutableDictionary()
        let CollectionOfAsyncCalls = DispatchGroup()
        
        var credentialsToIterate: [Credentials] = []
        var webKeyCredentialsToIterate: [String]  = []
        
        // it is set in ATTView based on user input, either fb_full or fb_limited
        let loginType = UserDefaults.standard.string(forKey: WebKeyhandler.User.loginType)
        
        let userCredentials: [Credentials] = [
            Credentials.fName,
            Credentials.lName,
            Credentials.email,
            Credentials.id,
            Credentials.fbID,
            Credentials.gender,
            Credentials.birthday,
            Credentials.deviceType,
            Credentials.pushToken,
            Credentials.workPlace,
            Credentials.workPosition,
            Credentials.accessToken,
            Credentials.ageRange,
            Credentials.schoolName,
            Credentials.schoolConcentration
        ]
        
        let userLimitedCredentials: [Credentials] = [
            Credentials.fName,
            Credentials.lName,
            Credentials.gender,
            Credentials.birthday,
            Credentials.deviceType,
            Credentials.email,
            Credentials.id,
            Credentials.fbID,
            Credentials.pushToken,
            Credentials.ageRange,
            Credentials.accessToken
        ]
        
        let webKeyLimitedCredentials: [String]  = [
            WebKeyhandler.User.firstName,
            WebKeyhandler.User.lastName,
            WebKeyhandler.User.gender,
            WebKeyhandler.User.dateOfBirth,
            WebKeyhandler.User.deviceType,
            WebKeyhandler.User.email,
            WebKeyhandler.User.userID,
            WebKeyhandler.User.fbID,
            WebKeyhandler.User.pushToken,
            WebKeyhandler.User.ageRange,
            WebKeyhandler.User.fbAccesToken
        ]
        
        let webKeyCredentials: [String]  = [
            WebKeyhandler.User.firstName,
            WebKeyhandler.User.lastName,
            WebKeyhandler.User.email,
            WebKeyhandler.User.userID,
            WebKeyhandler.User.fbID,
            WebKeyhandler.User.gender,
            WebKeyhandler.User.dateOfBirth,
            WebKeyhandler.User.deviceType,
            WebKeyhandler.User.pushToken,
            WebKeyhandler.User.employer,
            WebKeyhandler.User.workPosition,
            WebKeyhandler.User.fbAccesToken,
            WebKeyhandler.User.ageRange,
            WebKeyhandler.User.schoolName,
            WebKeyhandler.User.schoolConcentration
        ]
        //values of loginType in UserDEfaults are either UserDefaultsKeyHandler.Login.fb_full or UserDefaultsKeyHandler.Login.fb_limited. In this case "limited" is the default
        switch loginType {
        case UserDefaultsKeyHandler.Login.fb_full:
            credentialsToIterate = userCredentials
            webKeyCredentialsToIterate = webKeyCredentials
        default:
            credentialsToIterate = userLimitedCredentials
            webKeyCredentialsToIterate = webKeyLimitedCredentials
        }
        
        zip(credentialsToIterate, webKeyCredentialsToIterate).forEach { (credential, webKey) in
            CollectionOfAsyncCalls.enter()
            getFacebookUserDetails(credentials: credential, facebookUserInfo) { (response) in
                userInfo.setValue(response, forKey: webKey)
                UserDefaults.standard.setValue(response, forKey: webKey)
                CollectionOfAsyncCalls.leave()
            }
        }
        
        CollectionOfAsyncCalls.enter()
        getLatitudeAndLongitude(facebookUserInfo, mainController: mainController, callback: {
            (locationDict) in
            //This gets called right after login
            var lat = ""
            var long = ""
            
            if let latitude = locationDict[WebKeyhandler.Location.currentLat]{
                lat = String(describing: latitude)
            }
            if let longitude = locationDict[WebKeyhandler.Location.currentLong]{
                long = String(describing: longitude)
            }
            
            userInfo.setValue(lat, forKey: WebKeyhandler.Location.currentLat)
            UserDefaults.standard.setValue(lat, forKey: WebKeyhandler.Location.currentLat)
            
            userInfo.setValue(long, forKey: WebKeyhandler.Location.currentLong)
            UserDefaults.standard.setValue(long, forKey: WebKeyhandler.Location.currentLong)
            WebServiceController.shared.currentLongitude = long
            
            CollectionOfAsyncCalls.leave()
        })
        
        
    //Check if loginType is limited. If it is then we can set ent_facebook_profile_pic instead of this below.
        CollectionOfAsyncCalls.enter()
        mainController.getFacebookProfilePic(facebookUserInfo: facebookUserInfo, callback: {
            (response) in
            if response != [""] {
                UserDefaults.standard.setValue(response, forKey: WebKeyhandler.User.facebookProfilePics)
                userInfo.setValue(response, forKey: WebKeyhandler.User.facebookProfilePics)
            } else {
                let emptyStringArray = [String]()
                UserDefaults.standard.setValue(emptyStringArray, forKey: WebKeyhandler.User.facebookProfilePics)
                userInfo.setValue(emptyStringArray, forKey: WebKeyhandler.User.facebookProfilePics)
            }
            CollectionOfAsyncCalls.leave()

        })
        
        // When all async calls have returned this will be bounced back
        CollectionOfAsyncCalls.notify(queue: .main) {
            Log.log(message: "Finished all async requests in ParseFacebookUserInfo %@", type: .debug, category: Category.coreData, content: String(describing: ""))
            callback(userInfo)
        }
        
    }
    
    func getFacebookUserDetails(credentials: Credentials, _ facebookUserInfo: NSDictionary, callback: (String) -> Void) {
        
        
        switch credentials {
        case .fName:
            callback(facebookUserInfo[Credentials.fName.rawValue]! as! String)
        case  .lName:
            callback(facebookUserInfo[Credentials.lName.rawValue]! as! String)
        case  .email:
            guard let email = facebookUserInfo[Credentials.email.rawValue] as? String else { callback("") ; return  }
            callback(email)
        case  .id:
            //If the user id exists then return that if not return facebook id then we only return fb on first launch until post profile overwrites it.
            if let userID = UserDefaults.standard.string(forKey: WebKeyhandler.User.userID) {
                callback(userID)
            } else {
                callback(facebookUserInfo[Credentials.id.rawValue]! as! String)
            }
        case .fbID:
            callback(facebookUserInfo[Credentials.id.rawValue]! as! String)
        case  .gender:
            if  facebookUserInfo[Credentials.gender.rawValue] as! String? != nil {
                facebookUserInfo[Credentials.gender.rawValue] as! String == "female" ? callback("2") : callback("1")
            }else{
                callback("")
            }
            // facebookUserInfo[Credentials.gender.rawValue] as! String == "female" ? callback("") : callback("")
        case .birthday:
            if facebookUserInfo[Credentials.birthday.rawValue] != nil {
                
                // it is set in ATTView based on user input, either fb_full or fb_limited
                if UserDefaults.standard.string(forKey: WebKeyhandler.User.loginType)! == UserDefaultsKeyHandler.Login.fb_full {
                    
                    
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "MM/dd/yyyy"
                    let showDate = inputFormatter.date(from: String(describing: facebookUserInfo[Credentials.birthday.rawValue]!))
                    inputFormatter.dateFormat = "yyyy-MM-dd"
                    let resultString = inputFormatter.string(from: showDate!)
                    
                    // used to capture zodiac sign
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.date(from:resultString)!
                    WebServiceController.shared.dob = String(describing: date.zodiac)
                    
                    callback(resultString)
                    
                } else {
                    //                    1978-12-01 23:00:00 UTC
                    //                    1978-12-01 23:00:00 +0000
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                    let showDate = inputFormatter.date(from: String(describing: facebookUserInfo[Credentials.birthday.rawValue]!))
                    inputFormatter.dateFormat = "yyyy-MM-dd"
                    let resultString = inputFormatter.string(from: showDate!)
                    
                    // used to capture zodiac sign
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.date(from:resultString)!
                    WebServiceController.shared.dob = String(describing: date.zodiac)
                    
                    callback(resultString)
                }
            }else{
                
                callback("")

            }
        case .ageRange:
            // it is set in ATTView based on user input, either fb_full or fb_limited
            if UserDefaults.standard.string(forKey: WebKeyhandler.User.loginType)! == UserDefaultsKeyHandler.Login.fb_full {
                if facebookUserInfo.object(forKey: Credentials.ageRange.rawValue) != nil {
                    let ageRange = facebookUserInfo.object(forKey: Credentials.ageRange.rawValue)! as! NSDictionary
                    
                    let minimumAge = String(describing: ageRange.object(forKey: "min")!)
                    callback(minimumAge)
                } else {
                    callback("")
                }
            } else {
                // if fb_limited
                if facebookUserInfo.object(forKey: Credentials.ageRange.rawValue) != nil {
                    let ageRange = facebookUserInfo.object(forKey: Credentials.ageRange.rawValue)! as! UserAgeRange
                    let minimumAge = ageRange.min!.stringValue
                    callback(minimumAge)
                } else {
                    callback("")
                }
            }
            
        case .deviceType:
            callback(Credentials.deviceType.rawValue)
        case .pushToken:
            guard let deviceToken: String = UserDefaults.standard.object(forKey: Credentials.pushToken.rawValue) as? String else {
                callback("No_Token");
                return }
            callback(deviceToken)
        case .accessToken:
            // it is set in ATTView based on user input, either fb_full or fb_limited
            if UserDefaults.standard.string(forKey: WebKeyhandler.User.loginType)! == UserDefaultsKeyHandler.Login.fb_full {
                callback(AccessToken.current!.tokenString)
            } else {
                callback(AuthenticationToken.current!.tokenString)
            }
            
        case .workPlace:
            callback(provideResultsOf(workCredential: Credentials.workPlace.rawValue, facebookUserInfo))
        case .workPosition:
            callback( provideResultsOf(workCredential: Credentials.workPosition.rawValue, facebookUserInfo))
        case .schoolName:
            callback(provideResultsOf(educationCredential: Credentials.schoolName.rawValue, facebookUserInfo))
        case .schoolConcentration:
            callback(provideResultsOf(educationCredential: Credentials.schoolConcentration.rawValue, facebookUserInfo))
        }
    }
    
    func provideResultsOf(workCredential: String, _ facebookUserInfo: NSDictionary) -> String {
        var noCallback = true
        if let fbWork = facebookUserInfo["work"] {
            if let fbThisWork = (fbWork as? NSArray)?[0] {
                if let fbWorkEmployer = (fbThisWork as! NSDictionary)[workCredential] {
                    if let fbResult = (fbWorkEmployer as! NSDictionary)["name"] as? String {
                        noCallback = false
                        return fbResult
                    }
                }
            }
        }
        if noCallback {
            return ""
        }
    }
    
    func provideResultsOf(educationCredential: String, _ facebookUserInfo: NSDictionary) -> String {
        var education: String = ""
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day, .month, .year], from: date)
        let year =  components.year
        if let fbEducationList = facebookUserInfo["education"] {
            for index in 0..<(fbEducationList as! NSArray).count {
                if let fbEducation = (fbEducationList as? NSArray)?[index] {
                    if let fbEducationYear = (fbEducation as? NSDictionary)?["year"] {
                        if (fbEducationYear as! NSDictionary)["name"] as! String == String(describing: year) {
                            switch educationCredential {
                            case "school":
                                if let fbEducationName = (fbEducation as? NSDictionary)?["school"] {
                                    education = ((fbEducationName as! NSDictionary)["name"]) as! String
                                    return education
                                }
                            case "concentration":
                                if let fbEducationCon = (fbEducation as? NSDictionary)?["concentration"] {
                                    let arr: NSArray = fbEducationCon as! [NSDictionary] as NSArray
                                    education = ((arr[0] as! NSDictionary)["name"]!) as! String
                                    return education
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        return education
    }
    
    func getLatitudeAndLongitude(_ facebookUserInfo: NSDictionary, mainController: MainController, callback: @escaping (NSDictionary) -> Void) {
        var locationDict = NSDictionary()
        LocationController.shared.requestLocationPermission { status in
            switch status {
            case .notDetermined, .restricted, .denied:
                let failedDict : NSDictionary = ["":""]
                callback(failedDict)
            case .authorizedAlways, .authorizedWhenInUse, .authorized:
                mainController.getLocation(2, forceGetLocation: true, withAccuracy: .city) {
                    (response) in
                    locationDict = response
                    callback(locationDict)
                }
            }
        }
    }
    
    func getCurrentUsersFriends() {
        let mainController = MainController()
        if AccessToken.current != nil {
            // Todo: apply this to remove warnings http://stackoverflow.com/questions/39712372/fbsdkrequestconnection-warning-swift3
            let fbRequest = GraphRequest(graphPath: "me/friends", parameters: ["fields": "limit=10000"])
            _ = fbRequest.start(completion: { _, result, error -> Void in
                if error == nil && result != nil {
                    let facebookDict = result as! NSDictionary // FACEBOOK DATA IN DICTIONARY
                    
                    // callback(facebookData)
                    guard let facebookData = facebookDict["data"] else {
                        return
                    }
                    let facebookDataArray = facebookData as! NSArray
                    mainController.uploadFriends(friendsArray: facebookDataArray)
                }
            })
        }
        
    }
    
    // Todo: Move this to a more appropriate place.
    func getFacebookEventsArray(graphPath: String, parameters: [AnyHashable: Any]) {
        let mainController = MainController()
        var chosenGraphPath = graphPath
        var chosenParameters = parameters
        if graphPath == "" { // If run for the first time it is an empty string
            chosenGraphPath = "me/events?locale=en_US"
            chosenParameters = ["fields": "id,name,type,description,start_time,end_time,cover,place,attending_count,rsvp_status", "limit": "10000"]
        }
        
        self.getFacebookEvents(chosenGraphPath, parameters: chosenParameters) { (facebookEventsDict) in
            let events: [NSDictionary] = facebookEventsDict.object(forKey: "data") as! Array
            mainController.sendFacebookEvents(facebookEventDictionary: events)
            // When the first events have been collected then execute the next graphpath page recursively
            if let after = ((facebookEventsDict.object(forKey: "paging") as? NSDictionary)?.object(forKey: "cursors") as? NSDictionary)?.object(forKey: "after") as? String {
                self.getFacebookEventsArray(graphPath: "me/events?locale=en_US", parameters: ["after": after])
            } else {
                //print("Last pagination of Facebook Events")
            }
            
        }
        
    }
    
    // Todo: Move this to a more appropriate place.
    func getFacebookEvents(_ graphPath: String, parameters: [AnyHashable: Any], callback: @escaping (NSDictionary) -> Void) {
        if AccessToken.current != nil {
            let fbRequest = GraphRequest(graphPath: graphPath, parameters: parameters as! [String: Any])
            _ = fbRequest.start(completion: { _, result, error -> Void in
                
                if error == nil && result != nil {
                    let facebookData = result as! NSDictionary // FACEBOOK DATA IN DICTIONARY
                    // print(facebookData)
                    callback(facebookData)
                } else {
                    
                    Log.log(message: "Error could not getFacebookEvents Error: %@", type: .debug, category: Category.coreData, content: String(describing: error!))
                    
                
                }
            })
        }
    }
}
