//
//  URLHandler.swift
//  Krown
//
//  Created by KrownUnity on 31/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
struct URLHandler {
    //To ensure that production always has production URL. Remember this affects testing in diffen
#if DEBUG
    static let API_URL = "https://testenv.krownunity.com/api/"
    static let imageUploadDomain = "https://testenv.krownunity.com"  //This is used to test domain messages are coming from.
    static let xmpp_domain = "chattestenv.krownunity.com"
    static let xmpp_hostPort = 5222
#else
    static let API_URL = "https://api.krownunity.com/api/"
    static let imageUploadDomain = "https://api.krownunity.com"  //This is used to test domain messages are coming from.
    static let xmpp_domain = "chat.krownunity.com"
    static let xmpp_hostPort = 5222
#endif
    
    
    static let xmpp_domainResource = "@" + xmpp_domain + "/" + xmpp_domain
    static let userPreFix = "krownuser_"
    static let termsOfService = "https://www.krownapp.com/terms-of-service/"
    static let privacy = "https://www.krownapp.com/privacy/"
    static let help = "https://www.krownapp.com/help/"
    
    static let findSwipes = API_URL + "findSwipes"
    
    static let suggestedEvents = API_URL + "getSuggestedEvents"
    
    static let getMyEvents = API_URL + "getMyEvents"
    
    static let getEvent = API_URL + "getEvent"
    
    static let getMyUpcomingEvents = API_URL + "getMyUpcomingEvents"
    
    static let getMySuggestedEvents = API_URL + "getMySuggestedEvents"
    
    static let getMyPastEvents = API_URL+"getMyPastEvents"
    
    static let update_phone_email = API_URL+"update_phone_email"
    
    static let getMatchList = API_URL+"getProfileMatches"
    
    static let swipeAction = API_URL+"inviteAction"
    
    static let login = API_URL + "logMeIn"
    
    static let updateMyProfile = API_URL + "updateMyProfile"
    
    static let uploadProfileImage = API_URL + "upload_profile_image"
    
    static let uploadSingleProfileImage = API_URL + "upload_single_profile_image"
    
    static let deleteProfileImage = API_URL + "deleteProfileImage"
    
    static let uploadImage = API_URL + "upload_image"
    
    static let getProfileImage = API_URL + "get_user_profile_pic"
    
    static let uploadLocation = API_URL + "updateLocation"
    
    static let updatePreferences = API_URL + "updatePreferences"
    
    static let getPreferences = API_URL + "getPreferences"
    
    static let sendPushMessage = API_URL + "sendChatPush"
    
    static let addEventsAndMembers = API_URL + "addeventsandmembers"
    
    static let getEventAttendees = API_URL + "getEventAttendees"
    
    static let attendEvent = API_URL + "attendEvent"
    
    static let findUsersLiveDatingAtPOI = API_URL + "findUsersLiveDatingAtPOI"
    
    static let addFriends = API_URL + "addfriends"
    
    static let getShareVenues = API_URL + "getShareVenues"
    
    static let getProfile = API_URL + "getProfile"
    
    static let pauseProfile = API_URL + "pauseProfile"
    
    static let editProfile = API_URL + "editProfile"
    
    static let resetServerBadgeNumber = API_URL + "resetServerBadgeNumber"
    
    static let sendEmail = API_URL + "sendEmail"
    
    static let sendUserProfileEmail = API_URL + "sendUserProfileEmail"
    
    static let getSettings = API_URL + "getSettings"
    
    static let updateSetting = API_URL + "updateSetting"
    
    static let searchForInterest = API_URL + "searchForInterest"
    
    static let setInterests = API_URL + "setInterests"
    
    static let saveFeedback = API_URL + "saveFeedback"
    
    static let saveReportedInterests = API_URL + "reportInterests"
    
    static let deleteUser = API_URL + "deleteUser"
    
    static let liveLocationMapSearch = API_URL + "liveLocationMapSearch"
    static let getTopInterests = API_URL + "getTopInterests"
    
}
