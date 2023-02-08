//
//  WebServiceController.swift
//  Krown
//
//  Created by Anders Teglgaard on 30/08/2016.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Alamofire
import Foundation
import UIKit
import SDWebImageSwiftUI

class WebServiceController: ObservableObject  {
    static let shared = WebServiceController()
    @Published var profileImagesUrlArray: [String]
    @Published var dob = String()
    // used to track onboarding data
    @Published var userInfo = [String:Any]()
    @Published var currentLongitude = "" // tracks the need for location permission
    @Published var fbImageExists = false // tracks if FB profile image(s) exist and if so, there is no need to present OnboardingPhotos. In LoginController we check for FB profile images but after calling the postUserInfo and it is too late. We check for this variable in LoginView()
    @Published var loginProcessFinished = false // tracks if all functions from inside login() in LoginController are executed and thus all user data prepared correctly including FB profile images uploaded
    
    @Published var progressValueGender = 0.0
    @Published var progressValueDateOfBirth = 0.0
    @Published var progressValueLookingFor = 0.0
    @Published var progressValueProfilePhotos = 0.0
    @Published var progressValueInterests = 0.0
    @Published var progressValueLocation = 0.0
  
    init() {
        self.profileImagesUrlArray = [String]()
        
    }
    
    
    // Todo: Refactor most of this function to elsewhere
    func sendFacebookEvents(facebookEventDictionaryArray: [NSDictionary]) {
        
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        var eventArrayToPost = [String: AnyObject]()
        
        for (index, event) in facebookEventDictionaryArray.enumerated() {
            var dictParams = [String: AnyObject]()
            
            // In this we parse the dictionary from FB
            if let placeAny = event.object(forKey: WebKeyhandler.FacebookEvents.place) {
                let place = placeAny as! NSDictionary
                
                // Clean and make ready for insertion into mysql database removing " where it can exist
                let eventVenueNameCleaned = (place.object(forKey: WebKeyhandler.FacebookEvents.name) as! String?)!.replacingOccurrences(of: "'", with: "''")
                dictParams[WebKeyhandler.Events.eventVenueName] = eventVenueNameCleaned as AnyObject?
                
                if let locationAny = place.object(forKey: WebKeyhandler.FacebookEvents.location) {
                    let location = locationAny as! NSDictionary
                    
                    if let latitudeAny = location.object(forKey: WebKeyhandler.FacebookEvents.latitude) {
                        let latitude = latitudeAny as AnyObject?
                        dictParams[WebKeyhandler.Events.eventLatitude] = latitude
                        
                    } else {
                        dictParams[WebKeyhandler.Events.eventLatitude] = "" as AnyObject? // Default value for upload
                    }
                    
                    if let longitudeAny = location.object(forKey: WebKeyhandler.FacebookEvents.longitude) {
                        let longitude = longitudeAny as AnyObject?
                        dictParams[WebKeyhandler.Events.eventLongitude] = longitude
                        
                    } else {
                        dictParams[WebKeyhandler.Events.eventLongitude] = "" as AnyObject? // Default value for upload
                    }
                    
                    if let countryAny = location.object(forKey: WebKeyhandler.FacebookEvents.country) {
                        let country = countryAny as AnyObject?
                        dictParams[WebKeyhandler.Events.eventVenueCountry] = country
                        
                    } else {
                        dictParams[WebKeyhandler.Events.eventVenueCountry] = "" as AnyObject? // Default value for upload
                    }
                    
                    if let cityAny = location.object(forKey: WebKeyhandler.FacebookEvents.city) {
                        let city = cityAny as AnyObject?
                        dictParams[WebKeyhandler.Events.eventVenueCity] = city
                        
                    } else {
                        dictParams[WebKeyhandler.Events.eventVenueCity] = "" as AnyObject? // Default value for upload
                    }
                    
                    if let streetAny = location.object(forKey: WebKeyhandler.FacebookEvents.street) {
                        let street = streetAny as AnyObject?
                        dictParams[WebKeyhandler.Events.eventVenueStreet] = street
                        
                    } else {
                        dictParams[WebKeyhandler.Events.eventVenueStreet] = "" as AnyObject? // Default value for upload
                    }
                    
                    if let zipAny = location.object(forKey: WebKeyhandler.FacebookEvents.zip) {
                        let zip = zipAny as AnyObject?
                        dictParams[WebKeyhandler.Events.eventVenueZip] = zip
                        
                    } else {
                        dictParams[WebKeyhandler.Events.eventVenueZip] = "" as AnyObject? // Default value for upload
                    }
                    
                    if let stateAny = location.object(forKey: WebKeyhandler.FacebookEvents.state) {
                        let state = stateAny as AnyObject?
                        dictParams[WebKeyhandler.Events.eventVenueState] = state
                        
                    } else {
                        dictParams[WebKeyhandler.Events.eventVenueState] = "" as AnyObject? // Default value for upload
                    }
                }
            }
            
            if let coverPhotoAny = event.object(forKey: WebKeyhandler.FacebookEvents.cover) {
                let coverPhoto = coverPhotoAny as! NSDictionary
                
                let coverUrl = coverPhoto.object(forKey: WebKeyhandler.FacebookEvents.source) as AnyObject?
                dictParams[WebKeyhandler.Events.eventCoverUrl] = coverUrl
                
            }
            
            let type = event.object(forKey: WebKeyhandler.FacebookEvents.type)!
            
            let totalCount = event.object(forKey: WebKeyhandler.FacebookEvents.attending_count)! as AnyObject?
            
            // Clean and make ready for insertion into mysql database removing " where it can exist
            let eventNameCleaned = (event.object(forKey: WebKeyhandler.FacebookEvents.name) as! String?)?.replacingOccurrences(of: "'", with: "''")
            let eventDescriptionCleaned = (event.object(forKey: WebKeyhandler.FacebookEvents.description) as! String?)?.replacingOccurrences(of: "'", with: "''")
            
            dictParams[WebKeyhandler.Events.eventType] = type as AnyObject
            dictParams[WebKeyhandler.Events.eventName] = eventNameCleaned as AnyObject?
            dictParams[WebKeyhandler.Events.eventDescription] = eventDescriptionCleaned as AnyObject?
            dictParams[WebKeyhandler.Events.eventMemberID] = userID as AnyObject?
            dictParams[WebKeyhandler.Events.eventID] = event.object(forKey: WebKeyhandler.FacebookEvents.event_id) as AnyObject?
            dictParams[WebKeyhandler.Events.eventStartTime] = event.object(forKey: WebKeyhandler.FacebookEvents.start_time) as AnyObject?
            dictParams[WebKeyhandler.Events.eventEndTime] = event.object(forKey: WebKeyhandler.FacebookEvents.end_time) as AnyObject?
            dictParams[WebKeyhandler.Events.eventAttentingTotal] = totalCount
            dictParams[WebKeyhandler.Events.rsvpStatus] = event.object(forKey: WebKeyhandler.FacebookEvents.rsvp_status) as AnyObject?
            
            eventArrayToPost[String(index)] = dictParams as AnyObject
            
            if index % 50 == 0 && index != 0 || facebookEventDictionaryArray.count-index == 1 { // INFO: This is simple pagination either the array is nearly empty or it is divisible by 50 and should be sent. This has been done to make it more simple for the webserver to handle. PhP often has input_max_vars set to 1000 which will become a problem here and be truncated. Make this a for loop?
                
                request(URLHandler.addEventsAndMembers, dictParams: eventArrayToPost)
                eventArrayToPost.removeAll()
            }
            
        }
        
    }
    
    func liveDatingAtPOI(poiID: String , callback: @escaping (NSDictionary) -> Void){
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.Location.poiID] = poiID as AnyObject?
        
        request(URLHandler.findUsersLiveDatingAtPOI, dictParams: dictParams, callback: callback)
        
    }
    
    func getEventAttendees(fbEventID: String, callback: @escaping (NSDictionary) -> Void) {
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.Events.eventID] = fbEventID as AnyObject
        request(URLHandler.getEventAttendees, dictParams: dictParams, callback: callback)
    }
    
    func resetBadgeNumberOnServer(callback:@escaping (NSDictionary) -> Void) {
        
        // Bug: error in the code to reset the badge number needs testing to see if it works
        if let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as? String{

            var dictParams = [String: AnyObject]()
            dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
            
            if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                request(URLHandler.resetServerBadgeNumber, dictParams: dictParams, callback: callback)
            }
        }
        
    }
    
    func attendEvent(event: EventObject) {
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String

        dictParams[WebKeyhandler.Events.eventMemberID] = userID as AnyObject?
        dictParams[WebKeyhandler.Events.eventID] = event.id as AnyObject
        request(URLHandler.attendEvent, dictParams: dictParams)
    }
    
    func attendEventWithRSVP(rsvp_status: String, event_id: String, callback:@escaping (NSDictionary) -> Void) {
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.Events.rsvpStatus] = rsvp_status as AnyObject
        dictParams[WebKeyhandler.Events.event_ID] = event_id as AnyObject
        request(URLHandler.attendEvent, dictParams: dictParams, callback: callback)
    }
    
    func uploadEditedProfile(editedProfileObject: PersonObject) {
        
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = editedProfileObject.id as AnyObject
        dictParams[WebKeyhandler.User.userImage] = editedProfileObject.imageArray as AnyObject
        dictParams[WebKeyhandler.User.status] = editedProfileObject.status as AnyObject
        dictParams[WebKeyhandler.User.workPosition] = editedProfileObject.position as AnyObject
        dictParams[WebKeyhandler.User.schoolConcentration] = editedProfileObject.concentration as AnyObject
        
        request(URLHandler.editProfile, dictParams: dictParams) { (response) in
        }
        
    }
    
    func deleteProfileImage(profileImageUrl: String) {
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.User.userImage] = profileImageUrl as AnyObject
        request(URLHandler.deleteProfileImage, dictParams: dictParams) { (response) in
        }
        
    }
    
    func uploadFriends(friendsArray: NSArray) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        
        let friendsArrayPacked = NSMutableArray()
        
        for friend in friendsArray as! [NSDictionary] {
            let id = friend[WebKeyhandler.User.id]!
            friendsArrayPacked.add(id)
        }
        
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.Preferences.userFriends] = friendsArrayPacked as AnyObject?
        
        request(URLHandler.addFriends, dictParams: dictParams)
        
    }
    func getSwipes(_ userID: String, callback:@escaping (NSDictionary) -> Void) {
        let dictParams: [String: AnyObject] = [WebKeyhandler.User.userID: userID as AnyObject]
        request(URLHandler.findSwipes, dictParams: dictParams, callback: callback)
    }
    func getEvents(_ userID: String, callback:@escaping (NSDictionary) -> Void) {
        let dictParams: [String: AnyObject] = [WebKeyhandler.User.userID: userID as AnyObject]
        request(URLHandler.suggestedEvents, dictParams: dictParams, callback: callback)
    }
    func getMyEvents(_ callback:@escaping ([String:Any]) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
//        request(URLHandler.getMyEvents, dictParams: dictParams, callback: callback)
        request(URLHandler.getMyEvents, dictParams: dictParams) { responseDict in
            callback(responseDict as! [String:Any])
        }
    }
    
    func getMyUpcomingEvents(per_page: Int, page_number:Int,_ callback:@escaping ([String:Any]) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        dictParams[WebKeyhandler.User.per_page] = per_page as AnyObject
        dictParams[WebKeyhandler.User.page_number] = page_number as AnyObject
//        request(URLHandler.getMyUpcomingEvents, dictParams: dictParams, callback: callback)
        request(URLHandler.getMyUpcomingEvents, dictParams: dictParams) { responseDict in
            callback(responseDict as! [String:Any])
        }
    }
    
    func getMySuggestedEvents(per_page: Int, page_number:Int,_ callback:@escaping ([String:Any]) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        dictParams[WebKeyhandler.User.per_page] = per_page as AnyObject
        dictParams[WebKeyhandler.User.page_number] = page_number as AnyObject
//        request(URLHandler.getMySuggestedEvents, dictParams: dictParams, callback: callback)
        request(URLHandler.getMySuggestedEvents, dictParams: dictParams) { responseDict in
            callback(responseDict as! [String:Any])
        }
    }
    
    func getMyPastEvents(per_page: Int, page_number:Int,_ callback:@escaping ([String:Any]) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        dictParams[WebKeyhandler.User.per_page] = per_page as AnyObject
        dictParams[WebKeyhandler.User.page_number] = page_number as AnyObject
//        request(URLHandler.getMyPastEvents, dictParams: dictParams, callback: callback)
        request(URLHandler.getMyPastEvents, dictParams: dictParams) { responseDict in
            callback(responseDict as! [String:Any])
        }
    }
    
    func getEventDetail(_ fb_event_id: String, callback:@escaping ([String:Any]) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        dictParams[WebKeyhandler.Events.fb_event_id] = fb_event_id as AnyObject
//        request(URLHandler.getEvent, dictParams: dictParams, callback: callback)
        request(URLHandler.getEvent, dictParams: dictParams) { responseDict in
            callback(responseDict as! [String:Any])
        }
    }
    
    
    func update_phone_email(phone_number: String, email: String, callback:@escaping (NSDictionary) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        dictParams[WebKeyhandler.User.phone_number] = phone_number as AnyObject
        dictParams[WebKeyhandler.User.email] = email as AnyObject
        request(URLHandler.update_phone_email, dictParams: dictParams, callback: callback)
    }
    
    func getMatches(_ userID: String, callback: @escaping (NSDictionary) -> Void) {
        let dictParams: [String: AnyObject] = [WebKeyhandler.User.userID: userID as AnyObject]
        request(URLHandler.getMatchList, dictParams: dictParams, callback: callback)
    }
    
    func uploadImage(_ image: UIImage, callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        uploadImageVideo(URLHandler.uploadImage, fileExt: WebKeyhandler.imageHandling.jpg, image: image, dictParams: dictParams, callback: callback)
    }
    
    func uploadProfileImage(_ image: UIImage, imageIndex: String, callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.User.picIndex] = imageIndex as AnyObject?
        uploadImageVideo(URLHandler.uploadProfileImage, fileExt: WebKeyhandler.imageHandling.jpg, image: image, dictParams: dictParams, callback: callback)
    }
    
    func uploadSingleProfileImage(_ image: UIImage, callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        uploadImageVideo(URLHandler.uploadSingleProfileImage, fileExt: WebKeyhandler.imageHandling.jpg, image: image, dictParams: dictParams, callback: callback)
    }
    
    func uploadSingleProfileGIFImage(_ GIFData: Data, callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String

        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        uploadImageVideo(URLHandler.uploadSingleProfileImage, fileExt: WebKeyhandler.imageHandling.gif, GIFData: GIFData, dictParams: dictParams, callback: callback)
        
    }
    
    func uploadSingleProfileVideo(_ videoData: Data, callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        uploadImageVideo(URLHandler.uploadSingleProfileImage, fileExt: WebKeyhandler.imageHandling.mp4, GIFData: videoData, dictParams: dictParams){ (dictionary) in
                if let videoUrl = dictionary["url"] {
                    let newVideoUrl = videoUrl as! String
                    if self.profileImagesUrlArray.contains(newVideoUrl){} else {
                        // make sure to append only if the url doesn't alread exist in profileImagesUrlArray
                    self.profileImagesUrlArray.append(newVideoUrl)
                        callback(dictionary)
                }
            }
        }
        
    }
    
    func saveFeedback(_ image: [UIImage],description : String,feedback_categories : [String], callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.User.description] = description as AnyObject?
        dictParams[WebKeyhandler.User.feedback_categories] = feedback_categories as AnyObject?
        requestMultipleImage(URLHandler.saveFeedback, extenstion: WebKeyhandler.imageHandling.jpg, image: image, dictParams: dictParams, callback: callback)
    }
    
    func saveReportedInterests(_ description : String, feedback_categories : String, callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.User.description] = description as AnyObject?
        dictParams[WebKeyhandler.User.feedback_categories] = feedback_categories as AnyObject?
        request(URLHandler.saveReportedInterests, dictParams: dictParams, callback: callback)
    }
    
    func sendLocation(_ locationDict: NSDictionary,
                      callback: @escaping (NSDictionary) -> Void) {
        
        // bug: When the user opens the app without logging in and minimizes it it ask for background location. if accepted it crashes here.
        //Another bug is that on first load then we are trying to push location with the wrong fb_id.
        //This causes that the user does not receive results for matches on first load.
        if let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as? String
 {
            var dictParams = [String: AnyObject]()
            dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
            dictParams[WebKeyhandler.Location.currentLat] = String(describing: locationDict[WebKeyhandler.Location.currentLat]!) as AnyObject?
            dictParams[WebKeyhandler.Location.currentLong] = String(describing: locationDict[WebKeyhandler.Location.currentLong]!) as AnyObject?
            dictParams[WebKeyhandler.Location.course] = String(describing: locationDict[WebKeyhandler.Location.course]!) as AnyObject?
            dictParams[WebKeyhandler.Location.speed] = String(describing: locationDict[WebKeyhandler.Location.speed]!) as AnyObject?
            dictParams[WebKeyhandler.Location.altitude] = String(describing: locationDict[WebKeyhandler.Location.altitude]!) as AnyObject?
            dictParams[WebKeyhandler.Location.locationTime] = String(describing: locationDict[WebKeyhandler.Location.locationTime]!) as AnyObject?
            dictParams[WebKeyhandler.Location.horizontalAcc] = String(describing: locationDict[WebKeyhandler.Location.horizontalAcc]!) as AnyObject?
            dictParams[WebKeyhandler.Location.verticalAcc] = String(describing: locationDict[WebKeyhandler.Location.verticalAcc]!) as AnyObject?
            dictParams[WebKeyhandler.Location.visitedPOI] = String(describing: locationDict[WebKeyhandler.Location.visitedPOI]!) as AnyObject?
            
            
            request(URLHandler.uploadLocation, dictParams: dictParams, callback: callback)
            
        }
    }
    
    func getWebserviceProfileImage(userID: String, callback: @escaping (NSDictionary) -> Void) {
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        
        request(URLHandler.getProfileImage, dictParams: dictParams) { (response) in
                if let elements = response[WebKeyhandler.User.userPhotos] as? NSArray {
                for element in elements {
                    let object = element as! NSDictionary
                        let imageUrl = object[WebKeyhandler.imageHandling.image_url] as! String
                    
                        if self.profileImagesUrlArray.contains(imageUrl){} else {
                            // make sure to append only if the url doesn't alread exist in profileImagesUrlArray
                    self.profileImagesUrlArray.append(imageUrl)
                        }
                    }
                callback(response)
            }
        }
    }
    
    func resizeUploadImage(originalImage: UIImage){
        let originalImage = originalImage
        
        // Find size of image to set scaling
        let originalImageHeight = originalImage.size.height
        let originalImageWidth = originalImage.size.width
        var scaledImageWidth = CGFloat()
        var scaledImageHeight = CGFloat()
        if originalImageHeight  >= 1000 && originalImageHeight >= originalImageWidth { // if the size of height is more than 1000 px and picture is higher than wide
            scaledImageHeight = CGFloat(1000)
            scaledImageWidth = originalImageWidth / (originalImageHeight / scaledImageHeight) // calculates the new width of the image based on the factors from the original to the scaled image
        } else if originalImageWidth >= 1000 && originalImageWidth >= originalImageHeight { // if the size of width is more than 1000 px and picture is wider than high
            scaledImageWidth = CGFloat(1000)
            scaledImageHeight = originalImageHeight / (originalImageWidth / scaledImageWidth) // calculates the new height of the image based on the factors from the original to the scaled image
        } else {                            // If both height or width is not over 1000
            scaledImageHeight = originalImageHeight
            scaledImageWidth = originalImageWidth
        }
        
        let imageSize = CGSize.init(width: scaledImageWidth, height: scaledImageHeight)
        let scaledImage = originalImage.af.imageScaled(to: imageSize)
        
        self.uploadSingleProfileImage(scaledImage) { (dictionary) in
            if let photoUrl = dictionary["url"] {
                let newImageUrl = photoUrl as! String
                if self.profileImagesUrlArray.contains(newImageUrl){} else {
                    // make sure to append only if the url doesn't alread exist in profileImagesUrlArray
                self.profileImagesUrlArray.append(newImageUrl)
            }
        }
        }
        
    }
    
    func updateScope(_ scopeDict: NSDictionary, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        
        dictParams[WebKeyhandler.User.gender] = UserDefaults.standard.object(forKey: WebKeyhandler.User.gender) as AnyObject?
        dictParams[WebKeyhandler.Preferences.prefSex] = scopeDict[WebKeyhandler.Preferences.prefSex] as AnyObject?
        dictParams[WebKeyhandler.Preferences.lowerAge] = scopeDict[WebKeyhandler.Preferences.lowerAge] as AnyObject?
        dictParams[WebKeyhandler.Preferences.upperAge] = scopeDict[WebKeyhandler.Preferences.upperAge] as AnyObject?
        dictParams[WebKeyhandler.Preferences.prefRadius] = scopeDict[WebKeyhandler.Preferences.prefRadius] as AnyObject?
        dictParams[WebKeyhandler.Preferences.discFriends] = scopeDict[WebKeyhandler.Preferences.discFriends] as AnyObject?
        dictParams[WebKeyhandler.Preferences.discFriendsFriends] = scopeDict[WebKeyhandler.Preferences.discFriendsFriends] as AnyObject?
        dictParams[WebKeyhandler.Preferences.discUnrelated] = scopeDict[WebKeyhandler.Preferences.discUnrelated] as AnyObject?
        request(URLHandler.updatePreferences, dictParams: dictParams, callback: callback)
        
    }
    func sendPushMessage(_ message: String, receiverUserID: String, callback: @escaping (NSDictionary) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.message] = message as AnyObject?
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        dictParams[WebKeyhandler.User.receivingUserID] = receiverUserID as AnyObject?
        
        request(URLHandler.sendPushMessage, dictParams: dictParams, callback: callback)
    }
    
    func getSettings(_ callback: @escaping (NSDictionary) -> Void) {
        var dictParams = [String: AnyObject]()
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        request(URLHandler.getSettings, dictParams: dictParams, callback: callback)
    }
    
    func updateSettings(_ dictParams : [String: AnyObject], callback: @escaping (NSDictionary) -> Void) {
        // TODO: THe messages sent with photos etc will look weird they have to be converted
        var dictParameter = dictParams
        dictParameter[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        request(URLHandler.updateSetting, dictParams: dictParameter, callback: callback)
    }
    
    func getShareVenues(_ callback: @escaping (NSDictionary) -> Void) {
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        let dictParams: [String: AnyObject] = [WebKeyhandler.User.userID: userID as AnyObject]
        request(URLHandler.getShareVenues, dictParams: dictParams, callback: callback)
    }
    
    func swipeAction(_ userID: String, action: Int, swipeCardID: String, callback: @escaping (NSDictionary) -> Void) {
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.inviteeID] = swipeCardID as AnyObject?
        dictParams[WebKeyhandler.User.useAction] = action as AnyObject?
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        request(URLHandler.swipeAction, dictParams: dictParams, callback: callback)
        
    }
    
    func sendEmail(to: String, message: String, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        dictParams[WebKeyhandler.Email.emailFrom] = userID as AnyObject?
        dictParams[WebKeyhandler.Email.emailTo] = to as AnyObject?
        dictParams[WebKeyhandler.Email.emailMessage] = message as AnyObject?
        
        request(URLHandler.sendEmail, dictParams: dictParams, callback: callback)
        
    }
    func sendUserProfileEmail(to: String, message: String,report_type : String, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.UserProfileEmail.reported_id] = to as AnyObject?
        dictParams[WebKeyhandler.UserProfileEmail.report_text] = message as AnyObject?
        dictParams[WebKeyhandler.UserProfileEmail.report_type] = report_type as AnyObject?
        request(URLHandler.sendUserProfileEmail, dictParams: dictParams, callback: callback)
        
    }
    
    func pauseProfile(_ paused_for: String, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams["paused_for"] = paused_for as AnyObject
        
        request(URLHandler.pauseProfile, dictParams: dictParams, callback: callback)
        
    }
    func getProfile(_ otherUserID: String, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        let userID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as? String ?? ""
        dictParams[WebKeyhandler.User.userID] = userID as AnyObject?
        dictParams[WebKeyhandler.User.otherUserID] = otherUserID as AnyObject
        
        request(URLHandler.getProfile, dictParams: dictParams, callback: callback)
        
    }
    
    func deleteUser(callback:@escaping (Bool) -> Void){
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject
        request(URLHandler.deleteUser, dictParams: dictParams) { dict in
            if(dict.object(forKey: "ErrorCode") as? String == "1"){
                callback(true)
            } else {
                callback(false)
            }
        }

    }
    
    func liveLocationMapSearch(distance : String, latitude : Double, longitude : Double, callback: @escaping (NSDictionary) -> Void){
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject
        dictParams["longitude"] = "\(longitude)" as AnyObject
        dictParams["latitude"] = "\(latitude)" as AnyObject
        dictParams["distanceKM"] = distance as AnyObject
        
        request(URLHandler.liveLocationMapSearch, dictParams: dictParams, callback: callback)
    }
    
    func searchForInterest(interest: String, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.interest] = interest as AnyObject
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject
        
        request(URLHandler.searchForInterest, dictParams: dictParams, callback: callback)
        
    }
    
    func getTopInterests(id: String, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        dictParams[WebKeyhandler.User.userID] = id as AnyObject
        
        request(URLHandler.getTopInterests, dictParams: dictParams, callback: callback)
        
    }
    
    func setInterests(interests: [InterestModel], id: String, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        
        let interestsEncoded = try! JSONEncoder().encode(interests)
        let intereststoSend = String(data: interestsEncoded, encoding: .utf8)

        dictParams[WebKeyhandler.User.interests] = intereststoSend as AnyObject
        dictParams[WebKeyhandler.User.userID] = id as AnyObject

        request(URLHandler.setInterests, dictParams: dictParams, callback: callback)
        
    }
    
    func getScopeInfo(_ userID: String, callback: @escaping (NSDictionary) -> Void) {
        
        let dictParams: [String: AnyObject] = [WebKeyhandler.User.userID: userID as AnyObject]
        request(URLHandler.getPreferences, dictParams: dictParams, callback: callback)
        
    }
    func updateMyProfile(_ updateMyProfileDict: NSDictionary, callback: @escaping (NSDictionary) -> Void) {
        
        var dictParams = [String: AnyObject]()
        
        dictParams[WebKeyhandler.User.userID] = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as AnyObject?
        
        for (key, value) in updateMyProfileDict {
            dictParams[key as! String] = value as AnyObject
        }
        
        request(URLHandler.updateMyProfile, dictParams: dictParams, callback: callback)
    }
    
    func postUserInfo(_ userInfoDict: NSDictionary, callback: @escaping (NSDictionary) -> Void) {

        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            userInfoDict.setValue(UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String, forKey: WebKeyhandler.User.app_auth_token)
        } else {
            userInfoDict.setValue("ForceRefresh", forKey: WebKeyhandler.User.app_auth_token)
        }
        //Login functionality needs facebook login ID.
        if let fbID : String = UserDefaults.standard.object(forKey:WebKeyhandler.User.fbID) as? String {
            userInfoDict.setValue(fbID, forKey: WebKeyhandler.User.userID)
        }
        userInfoDict.setValue(UserDefaults.standard.string(forKey: WebKeyhandler.User.loginType), forKey: WebKeyhandler.User.loginType)
        request(URLHandler.login, dictParams: userInfoDict as! [String: AnyObject]) { (dict) in
            let user = dict["user"] as! [String:Any]
            let wave = user["waves"] as? [String:Any] ?? ["":""]
            setWaveUsedUp(wave: wave)
            
            UserDefaults.standard.set(dict.value(forKey: WebKeyhandler.User.app_auth_token)!, forKey: WebKeyhandler.User.app_auth_token)
            
            // user info we got back from logMeIn API endpoint from where we decide if we need to onboard the user
            self.userInfo = dict.value(forKey: "user") as! [String: Any]

            // collection of attributes without values for which we will onboard the user
            var onboardingAttributesWithoutValue = [String]()
            
            // 1. if dob data doesn't exist we will add it to an array from which we will observe the need for onboarding
            if self.userInfo[WebKeyhandler.User.dateOfBirth] as? String == nil || self.userInfo[WebKeyhandler.User.dateOfBirth] as? String == "" {
                onboardingAttributesWithoutValue.append(WebKeyhandler.User.dateOfBirth) // it could be WebKeyhandler.User.dateOfBirth
                // used so we can evaluate as String in LoginView
                self.userInfo[WebKeyhandler.User.dateOfBirth] = ""
            }
            
            // 2. if sex data doesn't exist we will add it to an array from which we will observe the need for onboarding
            if self.userInfo[WebKeyhandler.User.gender] as? String == nil || self.userInfo[WebKeyhandler.User.gender] as? String == "" {
                onboardingAttributesWithoutValue.append(WebKeyhandler.User.gender) // it could be WebKeyhandler.User.gender
                // used so we can evaluate as String in LoginView
                self.userInfo[WebKeyhandler.User.gender] = ""
            }
            
            // 3. if preference_sex data doesn't exist we will add it to an array from which we will observe the need for onboarding
            if self.userInfo[WebKeyhandler.Preferences.prefSex] as? String == nil || self.userInfo[WebKeyhandler.Preferences.prefSex] as? String == "" {
                onboardingAttributesWithoutValue.append(WebKeyhandler.Preferences.prefSex) // it could be WebKeyhandler.Preferences.prefSex
                // used so we can evaluate as String in LoginView
                self.userInfo[WebKeyhandler.Preferences.prefSex] = ""
            }
               
            // 4. if profile photos data (profile_pic_url) doesn't exist we will add it to an array from which we will observe the need for onboarding
         
            if self.userInfo[WebKeyhandler.User.profilePic] == nil || (self.userInfo[WebKeyhandler.User.profilePic] as? NSArray)?.count == 0 {
                    onboardingAttributesWithoutValue.append("profilePhotos")
                }
            
            // 5. if interests data doesn't exist we will add it to an array from which we will observe the need for onboarding
            if self.userInfo[WebKeyhandler.User.interests] == nil || (self.userInfo[WebKeyhandler.User.interests] as? NSArray)?.count == 0 {
                onboardingAttributesWithoutValue.append(WebKeyhandler.User.interests)
            }
            
            // if location authorization status is not determined we will add it to an array from which we will observe the need for onboarding
            if UserDefaults.standard.object(forKey: WebKeyhandler.Location.currentLong) as! String == "" {
                onboardingAttributesWithoutValue.append(WebKeyhandler.Location.location)
            }
            
            // check attributes without values, create the need for onboarding steps
            for item in onboardingAttributesWithoutValue {
                switch item {
                case WebKeyhandler.User.dateOfBirth: // it could be WebKeyhandler.User.dateOfBirth
                    let stepNumber = Double(onboardingAttributesWithoutValue.firstIndex(of: WebKeyhandler.User.dateOfBirth)! + 1) // it can't be nil since we are in a switch case
                    self.progressValueDateOfBirth = stepNumber/Double(onboardingAttributesWithoutValue.count)
                    
                case WebKeyhandler.User.gender: // it could be WebKeyhandler.User.gender
                    let stepNumber = Double(onboardingAttributesWithoutValue.firstIndex(of: WebKeyhandler.User.gender)! + 1) // it can't be nil since we are in a switch case
                    self.progressValueGender = stepNumber/Double(onboardingAttributesWithoutValue.count)
                    
                case WebKeyhandler.Preferences.prefSex: // it could be WebKeyhandler.Preferences.prefSex
                    let stepNumber = Double(onboardingAttributesWithoutValue.firstIndex(of: WebKeyhandler.Preferences.prefSex)! + 1) // it can't be nil since we are in a switch case
                    self.progressValueLookingFor = stepNumber/Double(onboardingAttributesWithoutValue.count)
                    
                case "profilePhotos":
                    let stepNumber = Double(onboardingAttributesWithoutValue.firstIndex(of: "profilePhotos")! + 1) // it can't be nil since we are in a switch case
                    self.progressValueProfilePhotos = stepNumber/Double(onboardingAttributesWithoutValue.count)
                    
                case WebKeyhandler.User.interests:
                    let stepNumber = Double(onboardingAttributesWithoutValue.firstIndex(of: WebKeyhandler.User.interests)! + 1) // it can't be nil since we are in a switch case
                    self.progressValueInterests = stepNumber/Double(onboardingAttributesWithoutValue.count)
                    
                case WebKeyhandler.Location.location:
                    let stepNumber = Double(onboardingAttributesWithoutValue.firstIndex(of: WebKeyhandler.Location.location)! + 1) // it can't be nil since we are in a switch case
                    self.progressValueLocation = stepNumber/Double(onboardingAttributesWithoutValue.count)
                    
                default:
                    continue
                }
                
                
            }
            
            var header : String
            if UserDefaults.standard.object(forKey: "app_auth_token") != nil {
                header = UserDefaults.standard.object(forKey: "app_auth_token")! as! String
            } else {
                header = "ForceRefresh"
            }
            //print("First Time User Login :~ Bearer \(header)")
            SDWebImageDownloader.shared.setValue("Bearer \(header)", forHTTPHeaderField: "authorization")
            
            callback(dict)
        }
    }
    
    func request(_ url: String, dictParams: [String: AnyObject]) {
        var headers: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            headers = [.authorization(bearerToken: "ForceRefresh"),]
        }
        AF.request(url, method: .post, parameters: dictParams, encoding: URLEncoding.default, headers: headers).responseString(completionHandler: { response in
            if(response.response != nil){
                self.LogoutOnAuthError(response: response)
            }
        })
            .response { response in
            if response.error != nil {
                Log.log(message: "JSON Response was malformed for request url %@", type: .debug, category: Category.networking, content: String(describing: response.request!.url!))            }
        }
        
    }
    
    func request(_ url: String, dictParams: [String: AnyObject], callback:@escaping (NSDictionary) -> Void) {
        var headers: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            headers = [.authorization(bearerToken: "ForceRefresh"),]
        }
        let request = AF.request(url, method: .post, parameters: dictParams, encoding: URLEncoding.default, headers: headers).responseString(completionHandler: { response in
            if(response.response != nil){
                self.LogoutOnAuthError(response: response)
            }
        })
            .response { response in
            if response.error != nil {
                Log.log(message: "JSON Response was malformed for request url %@", type: .debug, category: Category.networking, content: String(describing: response.request!.url!))
            }
            
        }
        
        
        request.validate().responseJSON { response in
            if let result = response.value as? NSDictionary {
                callback(result)
            } else {
                Log.log(message: "JSON Response was malformed for request url %@", type: .debug, category: Category.networking, content: String(describing: response.request!.url!))
            }
        }
        
    }
    
    
    func uploadImageVideo(_ url: String, fileExt: String, image: UIImage = UIImage(), GIFData: Data = Data(), dictParams: [String: AnyObject], callback:@escaping (NSDictionary) -> Void) {
        
        var imageData = Data()
        var fileExtension = String()
        fileExtension = fileExt
        var mimeType = String()
        switch fileExtension {
        case WebKeyhandler.imageHandling.mp4:
            fileExtension = "video.mp4"
            mimeType = "video/mp4"
            imageData = GIFData
        case WebKeyhandler.imageHandling.gif:
            fileExtension = "image.gif"
            mimeType = "image/gif"
            imageData = GIFData
            
        default:
            fileExtension = "image.jpg"
            mimeType = "image/jpg"
            imageData = image.jpegData(compressionQuality: 0.6)!
            
        }
        
        var headers: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            headers = [.authorization(bearerToken: "ForceRefresh"),]
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "ent_user_image", fileName: fileExtension, mimeType: mimeType)
            for (key, value) in dictParams {
                multipartFormData.append(value.data!(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
            }
            multipartFormData.append(Data("two".utf8), withName: "two")
        },to: url, headers: headers,
                  fileManager: FileManager.default, requestModifier: nil)
        .responseString { (response) in
            if(response.response != nil){
                self.LogoutOnAuthError(response: response)
            }
        }
        .responseJSON { response in
            if let dict : NSDictionary = response.value as? NSDictionary {
                callback(dict)
            }
            if (response.error != nil){
                Log.log(message: "JSON Response was malformed for request url %@", type: .debug, category: Category.networking, content: String(describing: response.request!.url!))
            }
        }
        
        
    }
    
    //This was made only for feedback
    func requestMultipleImage(_ url: String, extenstion: String, image: [UIImage] = [UIImage()], GIFData: Data = Data(), dictParams: [String: AnyObject], callback:@escaping (NSDictionary) -> Void) {
        
        var imageData = [Data()]
        var fileExtension = String()
        var mimeType = String()
        
        fileExtension = "image.jpg"
        mimeType = "image/jpg"
        if image.count != 0 {
            for i in 0...image.count - 1 {
                imageData.append(image[i].jpegData(compressionQuality: 0.6)!)
            }
        }
        
        var headers: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            headers = [.authorization(bearerToken: "ForceRefresh"),]
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            if imageData.count != 0 {
                for imageData in imageData {
                    multipartFormData.append(imageData, withName: "feedback_image[]", fileName: fileExtension, mimeType: mimeType)
                }
            }
            for (key, value) in dictParams {
                
                if key == "feedback_categories" {
                    var arr  = [String]()
                    arr = value as! [String]
                    for i in 0...arr.count-1{
                        multipartFormData.append((arr[i] as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: "feedback_categories[]")
                    }
                }else {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
        },to: url, headers: headers,
                  fileManager: FileManager.default, requestModifier: nil)
        .responseString { (response) in
            if (response.error != nil){
                Log.log(message: "JSON Response was malformed for request url %@", type: .debug, category: Category.networking, content: String(describing: response.request!.url!))
            }
            if(response.response != nil){
                self.LogoutOnAuthError(response: response)
            }
        }
        .responseJSON { response in
            if let dict : NSDictionary = response.value as? NSDictionary {
                callback(dict)
            }
        }
        
    }
    
    func LogoutOnAuthError(response: AFDataResponse<String>){
        if(response.response!.statusCode == 403){
            LoginController.shared.Logout()
        }
    }
    
    
}

