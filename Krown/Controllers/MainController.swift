//
//  MainController.swift
//  Krown
//
//  Created by KrownUnity on 25/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import MBProgressHUD
import SwiftLocation

class MainController: MatchObjectRepository, PersonObjectRepository, EventObjectRepository, ObservableObject {
    
    static var shared = MainController()

    func distributeMatchArray(_ id: String, callback: @escaping ([[MatchObject]]) -> Void) {

        PersonController.shared.getMatchArray(id, webService: WebServiceController.shared, callback: callback)

    }
    
    func getWaveArray(_ id: String, callback: @escaping ([MatchesModel]) -> Void) {

        PersonController.shared.getWaveModelArray(id, webService: WebServiceController.shared, callback: callback)

    }
    
    func distributeMatchChatArray(_ id: String, callback: @escaping ([MatchesModel]) -> Void) {

        PersonController.shared.getMatchChatArray(id, webService: WebServiceController.shared, callback: callback)

    }

    
    func distributeEventArrayFromMatched(_ id: String, callback: @escaping ([EventObject]) -> Void) {

        EventController.shared.getEventArrayFromMatched(id, callback: callback)

    }

    func distributeSwipeArray(_ id: String, callback: @escaping ([PersonObject]) -> Void) {

        PersonController.shared.getSwipeArray(id, webService: WebServiceController.shared, callback: callback)

    }

    func generateMatch(personDict: NSDictionary, callback: (MatchObject) -> Void) {
        PersonController.shared.match(personDict, callback: callback)
    }

    func distributeMatch(_ id: String, callback: @escaping (PersonObject) -> Void) {

        PersonController.shared.getProfile(id, webService: WebServiceController.shared, callback: callback)

    }

    func deleteUser (callback: @escaping (Bool) -> Void)
    {
        WebServiceController.shared.deleteUser(callback: callback)
    }
    
    func liveLocationMapSearch (distance : String, latitude : Double, longitude : Double, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.liveLocationMapSearch(distance: distance, latitude: latitude, longitude: longitude, callback: callback)
    }

    func uploadEditedProfile(editedProfileObject: PersonObject) {
        WebServiceController.shared.uploadEditedProfile(editedProfileObject: editedProfileObject)
    }

    func swipeAction(_ userID: String, action: Int, swipeCardID: String, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.swipeAction(userID, action: action, swipeCardID: swipeCardID, callback: callback)

    }

    func sendPushMessage( message: String, receiverUserID: String, callback: @escaping (NSDictionary) -> Void) {

        WebServiceController.shared.sendPushMessage(message, receiverUserID: receiverUserID) { (response) in
        callback(response)
        }
    }

    func resetBadgeNumberOnServer(_ callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.resetBadgeNumberOnServer( callback: callback)
    }
    
    func sendLocation(_ locationDict: NSDictionary, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.sendLocation(locationDict, callback: callback)
    }

    func getLocation(_ timeout: Double, forceGetLocation: Bool, withAccuracy: GPSLocationOptions.Accuracy, callback: @escaping (NSDictionary) -> Void) {
        LocationController.shared.getAndSetLocation(withAccuracy, setTimeout: timeout, forceGetLocation: forceGetLocation, callback: callback)
    }

    func attendEvent(event: EventObject) {
        WebServiceController.shared.attendEvent(event: event)
    }
    
    func attendEventWithRSVP(rsvp_status: String, event_id: String, callback:@escaping (NSDictionary) -> Void) {
        WebServiceController.shared.attendEventWithRSVP(rsvp_status: rsvp_status, event_id: event_id, callback: callback)
    }

    
    func getEventAttendees(attendees: NSArray, callback: @escaping ([MatchObject]) -> Void) {
        PersonController.shared.getEventAttendees(attendingMatches: attendees, callback: callback)
    }

    func sendFacebookEvents(facebookEventDictionary: [NSDictionary]) {
        WebServiceController.shared.sendFacebookEvents(facebookEventDictionaryArray: facebookEventDictionary)
    }

    func uploadFriends(friendsArray: NSArray) {
        WebServiceController.shared.uploadFriends(friendsArray: friendsArray)
    }
    func postProfile(_ userDict: NSDictionary, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.postUserInfo(userDict, callback: callback)
    }
    func login(_ view: UIViewController, callback : @escaping (Bool) -> Void) {

        LoginController().login(viewController: view, mainController: self, callback: callback)
    }

    func updateLoginInfo () {
        LoginController().updateLoginInfo()
    }
    func saveUser(facebookUser: NSDictionary) {
        UserController.shared.setUserToUserDefault(facebookUserInfo: facebookUser, mainController: self)
        
     }
    
    func parseUserFacebookInfo (facebookUserInfo: NSDictionary, callback : @escaping (NSDictionary) -> Void) {

        UserController.shared.parseFacebookUserInfo(facebookUserInfo, mainController: self, callback: callback)

    }
    func  getFacebookProfilePic(facebookUserInfo: NSDictionary, callback: @escaping ([String]) -> Void ) {

        LoginController().getFacebookProfilePic(facebookUserInfo, callback: callback)

    }

    func  getShareVenues( callback: @escaping (NSDictionary) -> Void ) {

        WebServiceController.shared.getShareVenues(callback)

    }
    func  pauseProfile(paused_for: String, callback: @escaping (NSDictionary) -> Void ) {
        WebServiceController.shared.pauseProfile(paused_for, callback: callback)
    }

    func  getProfile(userID: String, callback: @escaping (PersonObject) -> Void ) {

        PersonController.shared.getProfile(userID, webService: WebServiceController.shared) { (person) in
            callback(person)
        }

    }

    func getScopeInfo(callback : @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.getScopeInfo(String(describing: UserDefaults.standard.object(forKey: WebKeyhandler.User.userID)!), callback: callback)
    }
    
    func interrimLiveLocationView(poiID : String){
        MBProgressHUD.showAdded(to: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
        liveDatingAtPOI(poiID: poiID) { dict in
            if dict["ErrorCode"] as! String != "You need to be active at POI to find users"  && dict["ErrorCode"] as! String != "No users found at POI" {
                let activeUsersAtPOIArray = dict["ActiveUsersAtPOI"] as! NSArray
                PersonController.shared.matchObjectArray(activeUsersAtPOIArray, callback: { activeUsersAtPOI in
                    let swiftUIView = ListPeopleViews(matchesModel: activeUsersAtPOI, isEventFor: "", viewType: viewtype.nearbyView)
                    let hostingController = UIHostingController(rootView: swiftUIView)
                    hostingController.modalPresentationStyle = .fullScreen
                    let wave = UINavigationController(rootViewController: hostingController)
                    wave.modalPresentationStyle = .fullScreen
                    if var topController = UIApplication.shared.keyWindow?.rootViewController  {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        NotificationCenter.default.post(name: .setNearbyActive,  object: nil, userInfo: nil)
                     topController.present(wave, animated: true, completion: nil)
                    }
                    
                })
            } else if dict["ErrorCode"] as! String == "No users found at POI" {
                //Show a popup to alert the user that there is currently nobody single in live location.
                NotificationCenter.default.post(name: .setPeopleActive,  object: nil, userInfo: nil)
                AlertController().notifyUser(title: "No Singles Found", message: "Try again when someone new has entered", timeToDissapear: 5)
            }
            MBProgressHUD.hide(for: UIApplication.shared.windows[0].rootViewController!.view!, animated: true)
        }
    }
    
    func liveDatingAtPOI(poiID: String, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.liveDatingAtPOI(poiID: poiID, callback: callback)
    }
    
    func updateScopeInfo(scopeDict: NSDictionary, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.updateScope(scopeDict, callback: callback)
    }
    func updatemyProfile(updateMyProfileDict: NSDictionary, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.updateMyProfile(updateMyProfileDict, callback: callback)
    }
    func sendEmail(to: String, message: String, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.sendEmail(to: to, message: message, callback: callback)
    }
    func sendUserProfileEmail(to: String, message: String,report_type:String, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.sendUserProfileEmail(to: to, message: message,report_type: report_type, callback: callback)
    }
    func uploadImage(_ image: UIImage, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.uploadImage(image, callback: callback)
    }
    func deleteProfileImage(profileImageUrl: String) {
        WebServiceController.shared.deleteProfileImage(profileImageUrl: profileImageUrl)
    }

    func uploadProfileImage(_ image: UIImage, imageIndex: String, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.uploadProfileImage(image, imageIndex: imageIndex, callback: callback)
    }

    func uploadSingleProfileImage(_ image: UIImage, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.uploadSingleProfileImage(image, callback: callback)
    }
    
    func saveFeedback(_ image: [UIImage],description: String,feedback_categories:[String], callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.saveFeedback(image, description: description, feedback_categories: feedback_categories, callback:  callback)
    }
    
    func saveReportedInterests(_ description: String, feedback_categories : String, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.saveReportedInterests(description, feedback_categories: feedback_categories, callback: callback)
    }
    
    func uploadSingleProfileGIFImage(_ GIFData: Data, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.uploadSingleProfileGIFImage(GIFData, callback: callback)
    }

    func uploadSingleProfileVideo(_ videoData: Data, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.uploadSingleProfileVideo(videoData, callback: callback)
    }

    func getWebserviceProfileImages(_ userID: String, callback: @escaping (NSDictionary) -> Void) {
        WebServiceController.shared.getWebserviceProfileImage(userID: userID, callback: callback)
    }

}
