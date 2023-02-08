//
//  LoginController.swift
//  Krown
//
//  Created by KrownUnity on 06/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//
// Consider using the idea behind https://medium.com/ios-os-x-development/a-simple-swift-login-implementation-with-facebook-sdk-for-ios-version-4-0-1f313ae814da

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
import CoreLocation
import SwiftLocation
import Branch
import Alamofire
import FirebaseCrashlytics
import SwiftUI
import SDWebImage
import MBProgressHUD

class LoginController: ObservableObject {
    private let fbLoginManager: LoginManager = LoginManager()
    static let shared = LoginController()
    
    
    
    func login(viewController: UIViewController, mainController: MainController, callback : @escaping (Bool) -> Void) {
        self.getUserFacebookInfo(viewController, mainController: mainController, callback: {
            (response) in
                // check if age range has been written to UserDefaults from OnboardingAgeRange or that the user shared age range.
            
            let onboardingMinAge = (UserDefaults.standard.string(forKey: "onboardingMinAge") ?? "")
            let ageRange = (response.object(forKey: WebKeyhandler.User.ageRange) as? String ?? "")
            let dobFromFacebook = (response.object(forKey: WebKeyhandler.User.dateOfBirth) as? String ?? "")
            let dobFromOnboarding = (UserDefaults.standard.string(forKey: "onboardingDob") ?? "")
            var dob = ""
            if dobFromFacebook.isEmpty == false{ // set dob from facebook or onboarding
                dob = dobFromFacebook
            } else if dobFromOnboarding.isEmpty == false {
                dob = dobFromOnboarding
            }
            
            
            if (ageRange.isEmpty && onboardingMinAge.isEmpty) || dob.isEmpty {
                    // send a false callback which will fire OnboardingAgeRange view to show inside LoginView
                    callback(false)
                } else {
                    
                    // we have collected dob and age range in OnboardingAgeRange and we store it to response.objectt
                    if ageRange.isEmpty{
                        response.setValue(onboardingMinAge, forKey: WebKeyhandler.User.ageRange)
                    }
                    response.setValue(dob, forKey: WebKeyhandler.User.dateOfBirth)
                    
                    // we are sure ageRange is not nil, so we can check if the user is over 18. The user can't be minor since we perform age check when entering date of birth - the user must be at least 18. This is why we don't have an else statement which shows a minimum age alert and logs out if the user is a minor
                    if Int(response.object(forKey: WebKeyhandler.User.ageRange)! as! String)! >= 18 {
                        self.postUserInformation(response: response, callback: callback)
                    } else {
                        // Info: Pop an alert stating the user needs to be at least 18
                        let alert = UIAlertController(title: "Age Requirement", message: "You need to be at least 18 to use Krown", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        viewController.present(alert, animated: true, completion: {
                            self.Logout()
                        })
                    }
                    
                } // end of else statement if the onboardingMinAge is avaialble in USerDefaults
            //}
            // Crashlytics for tracking the unique user
            // Crashlytics.sharedInstance().setUserName(String(describing: UserDefaults.standard.object(forKey: self.WebKeyhandler.User.facebookID)))
            
            
        })
        
    }
    
    func postUserInformation(response: NSDictionary, callback : @escaping (Bool) -> Void){
        // Is the user above 18 years old?
        MainController.shared.postProfile(response) { (postResponseDict) in
            //Add ID to the response and overwrite the fb ID
            let userData = postResponseDict.object(forKey:"user") as! NSDictionary
            UserDefaults.standard.setValue(String(describing: userData.object(forKey:"id")!), forKey: WebKeyhandler.User.userID)
            response.setValue(String(describing: userData.object(forKey:"id")!), forKey: WebKeyhandler.User.userID)
            //In doubt if below changes anything.
            MainController.shared.saveUser(facebookUser: response)
            
            // Setting up branch for personalization of links etc. mainly for sharescreen and referrals
            Branch.getInstance().setIdentity(UserDefaults.standard.string(forKey: WebKeyhandler.User.userID))
            
            // Check if images are already present in the server. If not upload them.
            let FBImageUrlArray = response.object(forKey: WebKeyhandler.User.facebookProfilePics) as! [String]
            
            // if postUserInfo in WebServiceController determined profile photos should be asked during onboarding we reset it here
            if FBImageUrlArray.count != 0 {
                // with this we will know we don't have to show OnboardingPhotos, we check that in LopginView()
                WebServiceController.shared.fbImageExists = true
                // reset the value for progressValueProfilePhotos
                if WebServiceController.shared.progressValueProfilePhotos > 0.0 {
                    WebServiceController.shared.progressValueProfilePhotos = 0.0
                }
            }
            let CollectionOfAsyncCalls = DispatchGroup()
            self.profileImagesCheck(UserID: String(describing: userData.object(forKey:"id")!), mainController: MainController.shared, FBImageUrlArray: FBImageUrlArray){ needToUploadPicturesBool in
                // if there is need to upload images to Krown we get a true callback and upload them here
                if needToUploadPicturesBool {
                    //To ensure we enter DispatchGroup "CollectionOfAsyncCalls" enough times up until 6 pictures we run for loop. Since we have already check. Since we have to enter once for when 0 images are found loop breaks before collection of async calls.
                   
                    for (index,_ ) in FBImageUrlArray.enumerated() {
                        CollectionOfAsyncCalls.enter()
                        if index == 5 { //MAX 6 Pictures
                            break
                        }
                    }
                    
                    self.uploadProfileImages(UserID: String(describing: userData.object(forKey:"id")!), imageUrlArray: FBImageUrlArray, mainController: MainController.shared){ res in
                        CollectionOfAsyncCalls.leave()
                    }
                } else {
                    // we got a false callback from profileImagesCheck() and we can proceed with login
                    CollectionOfAsyncCalls.enter()
                    CollectionOfAsyncCalls.leave()
                    
                }
            }
            // When all async calls have returned this will be bounced back
            CollectionOfAsyncCalls.notify(queue: .main) {
                // we make sure login process is finished so HomeTabBarVC from LoginView() can be presented
                MBProgressHUD.hide(for: (UIApplication.shared.windows[0].rootViewController!.view)!, animated: true)
                WebServiceController.shared.loginProcessFinished = true
                callback(true)
            }
        }
        
    }
    
    
    
    
    func updateLoginInfo() {
        let mainController = MainController()
        let uiVC = UIViewController()
        getUserFacebookInfo(uiVC, mainController: mainController) { (responseDict) in
            mainController.postProfile(responseDict) { (_) in
            }
        }
        
    }
    
    func profileImagesCheck(UserID: String, mainController: MainController, FBImageUrlArray: [String], callback : @escaping (Bool) -> Void) {
        //This will always fail on first load.
        mainController.getWebserviceProfileImages(UserID) { (dictionary) in
            let profileImagesDict = dictionary.object(forKey: WebKeyhandler.User.userPhotos)
            let userWebserviceImageDictArray = profileImagesDict as! NSArray
                        
            if userWebserviceImageDictArray.count == 0 {
                if FBImageUrlArray.count != 0 {
                    UserDefaults.standard.setValue(FBImageUrlArray, forKey: WebKeyhandler.User.profilePic)
                    
                    // true in order to let know the calling function know we need to upload the images as well
                    callback(true)
                } else {
                    callback(false)
                }
                
            } else {
                var userProfileImageUrlArray = [String]()
                // Collects the data about images in an Array
                // The images from webservice are in correct order
                for image in userWebserviceImageDictArray {
                    let imageDict = image as! NSDictionary
                    let imageUrl = imageDict.object(forKey: "image_url")! as! String
                    userProfileImageUrlArray.append(imageUrl)
                }
                // false used just to let the calling function know there is no need to call another funciton
                callback(false)
            }
            
        }
        
    }
    
    func uploadProfileImages(UserID: String, imageUrlArray: [String], mainController: MainController, callback : @escaping (Bool) -> Void) {
        
        for (index, imageUrl) in imageUrlArray.enumerated() {
            if index == 6 { break }
            if UserDefaults.standard.string(forKey: WebKeyhandler.User.loginType) == UserDefaultsKeyHandler.Login.fb_limited{
                AF.request(imageUrl).responseImage { response in
                    
                    
                    if case .success(let image) = response.result {
                        mainController.uploadProfileImage(image, imageIndex: String(describing: index), callback: { (dictionary) in
                            if let photoUrl = dictionary["ResultingURL"] {
                                let newImageUrl = photoUrl as! String
                                
                                if WebServiceController.shared.profileImagesUrlArray.contains(newImageUrl){} else {
                                    // make sure to append only if the url doesn't alread exist in profileImagesUrlArray
                                    WebServiceController.shared.profileImagesUrlArray.append(newImageUrl)
                                }
                            }
                            
                            callback(true)
                        })
                    }
                }
                
            } else {
                AF.request(imageUrl).responseImage { response in
                    if case .success(let image) = response.result {
                        
                        mainController.uploadProfileImage(image, imageIndex: String(describing: index), callback: { (dictionary) in
                            if let photoUrl = dictionary["ResultingURL"] {
                                let newImageUrl = photoUrl as! String
                                if WebServiceController.shared.profileImagesUrlArray.contains(newImageUrl){} else {
                                    // make sure to append only if the url doesn't alread exist in profileImagesUrlArray
                                    WebServiceController.shared.profileImagesUrlArray.append(newImageUrl)
                                }
                            }
                            callback(true)
                        })
                        
                    }
                }
            }
            
        }
    }
    
    func getUserFacebookInfo(_ viewController: UIViewController, mainController: MainController, callback : @escaping (NSDictionary) -> Void) {
        
        self.loginWithFacebook(viewController, callback: {
            (response) in
            mainController.parseUserFacebookInfo(facebookUserInfo: response, callback: callback)
            
        })
    }
    
    func getFacebookProfilePic(_ facebookUserInfo: NSDictionary, callback: @escaping ([String]) -> Void) {
        
        // Info: test if no album -> fails send back an array with just the placeholder
        if let _ = facebookUserInfo["albums"] {
            for index in 0..<((facebookUserInfo["albums"] as! NSDictionary)["data"] as! NSArray).count {
                if (((facebookUserInfo["albums"] as! NSDictionary)["data"] as! NSArray)[index] as! NSDictionary)["name"]! as! String == "Profile pictures" || (((facebookUserInfo["albums"] as! NSDictionary)["data"] as! NSArray)[index] as! NSDictionary)["name"]! as! String == "Profile Pictures"{
                    
                    let requestString = ((((facebookUserInfo["albums"] as! NSDictionary)["data"] as! NSArray)[index] as! NSDictionary)["id"] as! String) + "/photos"
                    
                    let fbRequest = GraphRequest(graphPath: requestString, parameters: ["fields": "url,source"], httpMethod: HTTPMethod(rawValue: "GET"))
                    let connection = GraphRequestConnection()
                    connection.add(fbRequest, completion: { _, result, error in
                        if error == nil && result != nil {
                            let facebookData = result as! NSDictionary // FACEBOOK DATA IN DICTIONARY
                            
                            // Collects the data about images in an Array
                            // The images from facebook are in correct order
                            let facebookImageArray = (facebookData["data"] as! NSArray)
                            var facebookImageUrlArray = [String]()
                            for image in facebookImageArray {
                                let imageDict = image as! NSDictionary
                                let imageUrl = imageDict.object(forKey: "source")! as! String
                                facebookImageUrlArray.append(imageUrl)
                            }
                            
                            // TODO BUG SUGGESTIOON: Parse below to only strings to make it easier to manipulate.
                            
                            // If user has no profile picture then set the array to a generic image
                            if facebookImageUrlArray.count == 0 {
                                let url = ""
                                facebookImageUrlArray.append(url)
                                callback(facebookImageUrlArray)
                            } else {
                                callback(facebookImageUrlArray)
                            }
                        }
                    })
                    connection.start()
                }
            }
        } else if facebookUserInfo["ent_facebook_profile_pic"]  != nil {
            var facebookImageUrlArray = [String]()
            let imageUrl = facebookUserInfo["ent_facebook_profile_pic"] as! URL
            let stringUrl = imageUrl.absoluteString
            facebookImageUrlArray.append(stringUrl)
            callback(facebookImageUrlArray)
        } else {
            let url = ""
            var noImageArray = [String]()
            noImageArray.append(url)
            callback(noImageArray)
        }
        
    }
    
    func loginWithFacebook(_ view: UIViewController, callback : @escaping (NSDictionary) -> Void) {
        
        if AccessToken.current != nil {
            //fb_full was used for login
            self.getInformation(callback)
        } else if AuthenticationToken.current != nil {//fb_limited was used for login
            //Authtoken expires after one hour
            self.getLimitedInformation(callback)
        } else { //Called on first login // creates popup
            fbLoginGetUserInfo(view, callback: callback)
        }
    }
    
    func fbLoginGetUserInfo(_ view: UIViewController, callback : @escaping (NSDictionary) -> Void){
        fbLoginManager.logOut()
        
        var loginConfiguration = LoginConfiguration()
        // it is set in ATTView based on user input, either enabled or limited
        let loginType = UserDefaults.standard.string(forKey: WebKeyhandler.User.loginType)

        switch loginType! {
            //values of login_type in UserDefaults are either UserDefaultsKeyHandler.Login.fb_full or UserDefaultsKeyHandler.Login.fb_limited. In this case UserDefaultsKeyHandler.Login.fb_limited is the default
        case UserDefaultsKeyHandler.Login.fb_full:
            // Todo: how to handle tracking
            loginConfiguration = LoginConfiguration(permissions: [.email, .publicProfile, .userEvents, .userFriends, .userGender, .userBirthday, .userPhotos, .custom(WebKeyhandler.Facebook.user_age_range)], tracking: .enabled, nonce: UUID().uuidString)
        default:
            loginConfiguration = LoginConfiguration(permissions:[ .email, .publicProfile, .userFriends, .userBirthday, .custom(WebKeyhandler.Facebook.user_age_range), .userGender],tracking: .limited, nonce:  UUID().uuidString)
            
        }
        
        fbLoginManager.logIn(viewController: view, configuration: loginConfiguration!) { (result) in
            switch result {
            case .failed(let err):
                Log.log(message: "Facebook login error %@", type: .debug, category: Category.coreData, content: String(describing: err))
            case .cancelled:
                Log.log(message: "Facebook login cancelled %@", type: .debug, category: Category.coreData, content: String(describing: ""))
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                Log.log(message: "Facebook login success %@", type: .debug, category: Category.coreData, content: String(describing: ""))
                MBProgressHUD.showAdded(to: (UIApplication.shared.windows[0].rootViewController!.view)!, animated: true).label.text = "Loading"
                if loginType == UserDefaultsKeyHandler.Login.fb_full {
                    self.getInformation(callback)
                    
                } else {
                    self.getLimitedInformation(callback)
                }
                
            }
        }
        
        
    }
    
    func getLimitedInformation(_ callback: @escaping (NSDictionary)-> Void){
        let fbLimitedData = NSMutableDictionary()
        
        // getting user ID
        fbLimitedData["id"] = Profile.current?.userID
        
        // getting first and last name
        fbLimitedData["first_name"] = Profile.current?.firstName
        fbLimitedData["last_name"] = Profile.current?.lastName
        
        // getting image
        // parse the returned URL which contains access_token that we need to delete in order to properly show the profile image
        var components = URLComponents(string: Profile.current?.imageURL(forMode: .large , size: CGSize(width: 1200, height: 1200))?.absoluteString ?? "")
        
        var parameters = [URLQueryItem]()
        
        if let urlComponents = components {
            
            if let queryItems = urlComponents.queryItems {
                for queryItem in queryItems {
                    if queryItem.name != "access_token" {
                        let newItem = URLQueryItem(name: queryItem.name, value: queryItem.value!)
                        parameters.append(newItem)
                    }
                }
            }
            components?.query = nil
            components?.queryItems = parameters
            
            fbLimitedData["ent_facebook_profile_pic"] = components?.url!
        }
        
        // getting pre-populated email
        fbLimitedData["email"] = Profile.current?.email
        
        // getting pre-populated friends list
        fbLimitedData["friendIDs"] = Profile.current?.friendIDs
        
        // getting pre-populated user birthday
        fbLimitedData["birthday"] = Profile.current?.birthday
        
        // getting pre-populated age range
        fbLimitedData["age_range"] = Profile.current?.ageRange
        
        // getting user gender
        fbLimitedData["gender"] = Profile.current?.gender ?? UserDefaults.standard.value(forKey: WebKeyhandler.User.gender)
        
        // getting id token string
        fbLimitedData[WebKeyhandler.User.fbAccesToken] = AuthenticationToken.current?.tokenString
        
        callback(fbLimitedData)
    }
    
    func getInformation(_ callback: @escaping (NSDictionary) -> Void) {
        // Refresh access token on every request
        AccessToken.refreshCurrentAccessToken { (_, _, error) in
            if error != nil {
                Log.log(message: "The facebook Access was not refreshed due to: %@", type: .debug, category: Category.coreData, content: String(describing: error))
            }
        }
        let fbRequest = GraphRequest(graphPath: "me?locale=en_US", parameters: ["fields": "id,first_name,last_name,email,gender,age_range,cover,albums,birthday,events"])
        
        let connection = GraphRequestConnection()
        connection.add(fbRequest, completion: { _, result, error in
            
            
            if error == nil && result != nil {
                let facebookData = result as! NSDictionary // FACEBOOK DATA IN DICTIONARY
                callback(facebookData)
                //                self.fbLoginManager.logOut()
            } else if error != nil{
                Log.log(message: "Facebook Login encountered an error - %@", type: .debug, category: Category.thirdParty, content: String(describing: error?.localizedDescription))
            }
        })
        connection.start()
        
    }
    
    func Logout() {
        //Check if user is already logged out
        if (UserDefaults.standard.object(forKey: UserDefaultsKeyHandler.Login.userLogin) != nil){
            SwiftLocation.restoreState()
            Branch.getInstance().logout()
            // TODO: clear user and send the user back to the login screen
            if let appDomain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
            }
            UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
            UserDefaults.standard.synchronize()
            OneChat.sharedInstance.disconnect()
            LoginManager().logOut()
            Log.log(message: "User logout success! %@", type: .debug, category: Category.login, content: "")
            AuthManager.shared.setLoginPage((UIApplication.shared.delegate!.window!)!)
        }
    }
    
    
}
