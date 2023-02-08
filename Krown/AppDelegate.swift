//
//  AppDelegate.swift
//  Krown
//
//  Created by KrownUnity on 25/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//
import UIKit
import FBSDKCoreKit
import CocoaLumberjack
import Flurry_iOS_SDK
import AVFoundation
import Branch
import UXCam
import UserNotifications
import IQKeyboardManagerSwift
import SwiftLocation
import Firebase
import FirebaseDynamicLinks
import FirebaseAnalytics
import FirebasePerformance
import FirebaseCrashlytics
import SDWebImage
import Siren
import SwiftUI
import SwiftEntryKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let mainController = MainController()
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // refer func setupinitialController for the change.
        NetworkManager.shared.startMonitoring()
        
        // Setup facebook to remember from last launch
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        getProfile()
        
        // Select inital view controller to run
        selectInitialViewController()
        
        // Setup siren
        setupSiren()
        
        // Setup sliding keyboard
        IQKeyboardManager.shared.enable = true
        
        // Crashlytics setup
        FirebaseApp.configure()
        
        // Setup location tracking in background
        if let _ = launchOptions?[UIApplication.LaunchOptionsKey.location] {
            Log.log(message: "The app was opened in the background due to location %@", type: .debug, category: Category.coreData, content: String(describing: ""))
            
        }
        //Check if user has done specific things before before
        if UserDefaults.standard.value(forKey: UserDefaultsKeyHandler.Login.hasClickWaveBefore) == nil {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeyHandler.Login.hasClickWaveBefore)
        }
        if UserDefaults.standard.value(forKey: UserDefaultsKeyHandler.Login.countOfDiscoverPeopleAccesses) == nil {
            UserDefaults.standard.set(0, forKey: UserDefaultsKeyHandler.Login.countOfDiscoverPeopleAccesses)
        } else if let EnterDescoverPeopleCount : Int = UserDefaults.standard.value(forKey: UserDefaultsKeyHandler.Login.countOfDiscoverPeopleAccesses) as? Int {
            if EnterDescoverPeopleCount < 3 {
                if (UserDefaults.standard.object(forKey: UserDefaultsKeyHandler.Login.userLogin)) != nil &&
                    AccessToken.current != nil {
                    UserDefaults.standard.set(EnterDescoverPeopleCount + 1, forKey: UserDefaultsKeyHandler.Login.countOfDiscoverPeopleAccesses)
                }
            }
        }
        
        // Start UXCAM to be able to view the users behavior in the app
        // TODO: UXCAM seems to block the mainthread which makes the app seem unresponsive when swiping.
        // UXCam.start(withKey: "0b9b8c8762ebef9")
        
#if DEBUG
        // XMPP Logging activation - Outcommented for Production
        if(Log.XMPPLoggingIsOn){
            DDLog.add(DDOSLogger.sharedInstance)
        }
#endif

        // XMPP Chat start
        OneChat.start(archiving: true, delegate: nil) { (_, error) -> Void in
            if let _ = error {
                // handle start errors here
                Log.log(message: "XMPP did not connect %@", type: .debug, category: Category.chat, content: String(describing: ""))
            } else {
                // Succes starting XMPP Services (Not logging in)
                Log.log(message: "XMPP service is started %@", type: .debug, category: Category.chat, content: String(describing: ""))
            }
            
        }
        
        
        //check if token is allowed and updated if needed.
        getNotificationSettings()
        
        // Allows the user to listen to music while in the app
        allowBackgroundAudio()
        
        // Initiates flurry analytics
        Flurry.startSession(apiKey: "BJ4C7SKGWWKMXJFTFSGX")
        Flurry.log(eventName: "Application Launched")
        
        // Initiates Branch.io
        Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                // ... insert custom logic here ...
                let desc = params?.description
                Log.log(message: "Branch params: %@", type: .debug, category: Category.thirdParty, content: String(describing: desc!))
            }
        })
        
        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        // pass the url to the handle deep link call
        Branch.getInstance().handleDeepLink(url)
        
        let handled: Bool = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        return handled
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            return true
        }
        return false
    }
    
    // Respond to Universal Links for Branch.io
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        let handled = DynamicLinks.dynamicLinks()
            .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
                guard error == nil else {
                    Log.log(message: "universal links: %@", type: .debug, category: Category.thirdParty, content: String(describing: error?.localizedDescription ?? ""))
                    return
                }
                if let dynamicLink = dynamiclink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
        Branch.getInstance().continue(userActivity)
        return handled
    }
    
    func handleIncomingDynamicLink(_ dynamiclink: DynamicLink) {
        guard let url = dynamiclink.url else {
            Log.log(message: "Missing dynamic link URL %@", type: .debug, category: Category.thirdParty, content: "")
            return
        }
        globalConstant.eventIDFromDeepLink = getQueryStringParameter(url: url.absoluteString, param: "eventID") ?? ""
        //print("Your incoming link parameter is \(getQueryStringParameter(url: url.absoluteString, param: "eventID") ?? "")")
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            //print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
    }

func getProfile()
{
    if UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) != nil {
        if let ownUserID = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as? String
        {
            MainController.shared.getWebserviceProfileImages(ownUserID){ response in
            }
            MainController.shared.getProfile(userID: ownUserID, callback: { (obj) in
                globalConstant.personObject = obj
            })
        }
    }
}
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEvents.shared.activateApp()
        
        // Set notifications badge to 0 again locally
        application.applicationIconBadgeNumber = 0
        // Set badgenumber to zero on server
        let main = MainController()
        main.resetBadgeNumberOnServer { (_) in
            
        }
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        OneChat.stop()
        NetworkManager.shared.stopMonitoring()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification launchOptions: [AnyHashable: Any]) {
        
        Branch.getInstance().handlePushNotification(launchOptions)
        //print("A remote notification was received with \(launchOptions)")
        let sender_id = String(describing: (launchOptions["data"] as! Dictionary<String, Any>)["sender_id"]!)
        let category = String(describing:(launchOptions["aps"] as! Dictionary<String, Any>)["category"]!)
        
        if (sender_id != "" && category == WebKeyhandler.notification.liveMatch) {
            //This is a live match. Now the user should be asked if they want to accept. This only works from a notification but should work from the app itself. Never rely only on notifications.
            //This is currently only set up for testing.
            let own_id = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
            AlertController().liveMatchPopup(own_id: own_id, sender_id: sender_id)
        }
        if (sender_id != "" && category == WebKeyhandler.notification.chatNotification && application.applicationState == UIApplication.State.inactive){ // testing application state to not trigger in active mode
            ShowChatOnRemoteNotification(userID: sender_id)
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
            
        case "SWIPE_ACTION":
            Log.log(message: "SwipeAction Clicked %@", type: .debug, category: Category.notifications, content: "")
            // first action
            
        case "IGNORE_ACTION":
            Log.log(message: "IgnoreAction Clicked %@", type: .debug, category: Category.notifications, content: "")
            // second action
            
        default:
            //print("Default action run")
            break
        }
        
        completionHandler()
        
    }
    
    // #### should make the music play when the app is running ####
    func allowBackgroundAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .moviePlayback)
        } catch {
            NSLog("AVAudioSession SetCategory - Playback:MixWithOthers failed")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        Log.log(message: "This is the pushtoken %@", type: .debug, category: Category.notifications, content: token)
        
        UserDefaults.standard.set(token, forKey: UserDefaultsKeyHandler.User.deviceToken)
        UserDefaults.standard.synchronize()
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.log(message: "Failed to register: %@", type: .debug, category: Category.notifications, content: String(describing: error))
        
    }
    
    func selectInitialViewController() {
        // Info: If logged in then take the user to the home screen, if not take the user to login screen
        window = UIWindow(frame: UIScreen.main.bounds) // if PinpointKit is removed then change it to the old value
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            AuthManager.shared.setInitialScreen(self.window!)
            
        }
        // INFO: Logic is to log user in directly if there is a valid accesstoken and the userdefaults is full of info
    }
    
    func setupSiren() {
        // When updated on the appstore this creates a popup that forces the user to update
        // TODO: Test this in appstore. It has not been tested.
        Siren.shared.rulesManager = RulesManager(majorUpdateRules: .critical, minorUpdateRules: .critical, patchUpdateRules: .annoying, revisionUpdateRules: .default, showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
        Siren.shared.apiManager = APIManager(country: .denmark)
        Siren.shared.wail()
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
func shareContent(_ messageStr : String, eventID : String, imgUrl: String)
{
    var components = URLComponents()
    components.scheme = "https"
    components.host = "www.raywenderlich.com"
    components.path = "/about"
    
    let itemIDQueryItem = URLQueryItem(name: "eventID", value: eventID)
    components.queryItems = [itemIDQueryItem]
    
    guard let linkParameter = components.url else { return }
    
    let domain = "https://krownapp.page.link"
    guard let linkBuilder = DynamicLinkComponents
        .init(link: linkParameter, domainURIPrefix: domain) else {
        return
    }
    
    if let myBundleId = Bundle.main.bundleIdentifier {
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
    }
    // 2
    linkBuilder.iOSParameters?.appStoreID = "1441164558"
    // 3
    linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
    linkBuilder.socialMetaTagParameters?.title = "Krown"
    linkBuilder.socialMetaTagParameters?.descriptionText = messageStr
    linkBuilder.socialMetaTagParameters?.imageURL = URL(string: imgUrl)!
    guard let longURL = linkBuilder.url else { return }
    Log.log(message: "The long dynamic link is %@", type: .debug, category: Category.notifications, content: longURL.absoluteString)
    linkBuilder.shorten { url, warnings, error in
        if let error = error {
            Log.log(message: "Dynamic link error %@", type: .debug, category: Category.notifications, content: String(describing: error))
            return
        }
        if let warnings = warnings {
            for warning in warnings {
                Log.log(message: "Dynamic link warning %@", type: .debug, category: Category.notifications, content: warning)
            }
        }
        guard let url = url else { return }
        Log.log(message: "Short url to share %@", type: .debug, category: Category.notifications, content: url.absoluteString)
        shareTxt(messageStr + " - " + url.absoluteString)
    }
}

func shareTxt(_ msg: String) {
    let activityViewController = UIActivityViewController(activityItems: [msg], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows[0].rootViewController!.view // so that iPads won't crash
    
    // exclude some activity types from the list (optional)
    activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
    
    // present the view controller
    UIApplication.shared.windows[0].rootViewController!.present(activityViewController, animated: true, completion: nil)
    
}
func getQueryStringParameter(url: String, param: String) -> String? {
    guard let url = URLComponents(string: url) else { return nil }
    return url.queryItems?.first(where: { $0.name == param })?.value
}

func ShowChatOnRemoteNotification(userID : String){
    MainController().getProfile(userID: userID, callback: { (personObject) in
        // Go to chat if user wants to interact.
        let chatView = MatchesChatViewVC()
        // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
        let jidString = URLHandler.userPreFix + "\(personObject.id)@" + URLHandler.xmpp_domain
        OneChats.addUserToChatList(jidStr: jidString, displayName: personObject.name)
        let user = OneRoster.userFromRosterForJID(jid: URLHandler.userPreFix + personObject.id + URLHandler.xmpp_domainResource)
        
        chatView.recipientXMPP = user
        chatView.matchObject = MatchObject(id: personObject.id, name: personObject.name, imageArray: personObject.imageArray, lastActiveTime: String(describing: Date()), distance: personObject.distance, interests: [InterestModel]())
        chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: jidString, senderDisplayName: "")
        
        if user != nil {// Check to make sure that the user is there
            let chat = UINavigationController(rootViewController: chatView)
            chat.modalPresentationStyle = .fullScreen
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromTop
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            UIApplication.shared.windows[0].rootViewController!.view.window!.layer.add(transition, forKey: kCATransition)
            UIApplication.shared.windows[0].rootViewController!.present(chat, animated: false, completion: nil)
            
        } else {
            // Present messages that there is a network error to the server
        }
    })
}
                                
                                
