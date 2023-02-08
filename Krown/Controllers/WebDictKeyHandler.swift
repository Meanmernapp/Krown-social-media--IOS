//
//  WebKeyhandler.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
struct WebKeyhandler {
    struct Location{
        static let currentLat = "current_latitude"
        static let currentLong = "current_longitude"
        static let speed = "speed"
        static let course = "course"
        static let altitude = "altitude"
        static let horizontalAcc = "horizontal_accuracy"
        static let verticalAcc = "vertical_accuracy"
        static let locationTime = "time_stamp"
        static let visitedPOI = "visited_POI"
        static let location = "location"
        static let poiID = "poi_id"

    }
    
    struct POI {
        static let liveLocationStatus = "liveLocationStatus"
        static let is_already_active_within_location = "is_already_active_within_location"
        static let first_visit = "first_visit"
        static let was_no_longer_active_within_location = "was_no_longer_active_within_location"
        static let not_at_location = "not_at_location"
        static let left_location_active_within_time_limit = "left_location_active_within_time_limit"
        static let was_active_not_at_location = "was_active_not_at_location"
        static let not_enough_locations_recorded_remaining_active = "not_enough_locations_recorded_remaining_active"
        static let liveLocation = "liveLocation"
        static let allowShowingDiscoverNearby = "allowShowingDiscoverNearby"
    }
    
    struct User {
            static let userID = "user_id"
            static let id = "id"
            static let fbID = "fb_id" //This is only used for login and should not be used elsewhere
            static let otherUserID = "getProfile_user_id"
            static let firstName = "first_name"
            static let lastName = "last_name"
            static let email = "email"
            static let gender = "sex"
            static let phone_number = "phone_number"
            static let dateOfBirth  = "dob"
            static let profilePic = "profile_pic_url"
            static let facebookProfilePics = "facebook_profile_pic"
            static let deviceType = "device_type"
            static let employer = "employer"
            static let workPosition = "position"
            static let schoolConcentration = "concentration"
            static let schoolName = "school"
            static let pushToken = "push_token"
            static let ageRange = "age_range"
            static let fbAccesToken = "fb_access_token"
            static let limitedTokenString = "tokenString"
            static let loginType = "login_type"
            static let status = "status"
            static let picIndex = "index"
            static let userImage = "image_url"
            static let imageNumber = "imageNumber"
            static let inviteeID = "ent_invitee_id"
            static let useAction = "ent_user_action"
            static let message = "ent_message"
            static let receivingUserID = "receiving_user_id"
            static let interest = "interest"
            static let per_page = "per_page"
            static let page_number = "page_number"
            static let description = "description"
            static let feedback_categories = "feedback_categories"
            static let feedback_image = "feedback_image"
            static let app_auth_token = "app_auth_token"
            static let userPhotos = "Userphotos"
            static let interests = "interests"
            static let isPaused = "paused"
            static let isWaveUsedUp = "waveUsed"
            static let waveResetAt = "waveResetAt"
        
    }
    struct Events {
        // Events
        static let eventID = "id"
        static let fb_event_id = "fb_event_id"
        static let event_ID = "event_id"
        static let eventMemberID = "member_id"
        static let eventStartTime = "start_time"
        static let eventEndTime = "end_time"
        static let eventName = "event_title"
        static let eventType = "event_type"
        static let eventDescription = "description"
        static let eventCoverUrl = "cover_url"
        static let eventLatitude = "place_latitude"
        static let eventLongitude = "place_longitude"
        static let eventVenueName = "place_name"
        static let eventVenueCountry = "place_country"
        static let eventVenueState = "place_state"
        static let eventVenueCity = "place_city"
        static let eventVenueStreet = "place_street"
        static let eventVenueZip = "place_zip"
        static let eventAttentingTotal = "attending_count"
        static let rsvpStatus = "rsvp_status"
    }
    struct Preferences {
        static let discFriends = "ent_disc_friends"
        static let discFriendsFriends = "ent_disc_friends_friends"
        static let discUnrelated = "ent_disc_unrelated"
        static let userFriends = "ent_user_friends"
        static let prefSex = "preference_sex"
        static let lowerAge = "preference_lower_age"
        static let upperAge = "preference_upper_age"
        static let prefRadius = "preference_radius"

    }
    struct Email {
        // Email
        static let emailFrom = "emailFrom"
        static let emailTo = "emailTo"
        static let emailMessage = "emailMessage"
        
    }
    struct UserProfileEmail {
        // Email
        static let reported_id = "reported_id"
        static let report_text = "report_text"
        static let report_type = "report_type"
    }
    
    struct Chat {
    // XMPP
    static let xmppMatch = "match"
    static let xmppChat = "chat"
    static let xmppLocation = "location"
    static let xmppPhoto = "photo"
    }
    
    struct FacebookEvents {
        static let place = "place"
        static let name = "name"
        static let location = "location"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let country = "country"
        static let city = "city"
        static let street = "street"
        static let zip = "zip"
        static let state = "state"
        static let cover = "cover"
        static let source = "source"
        static let type = "type"
        static let attending_count = "attending_count"
        static let description = "description"
        static let event_id = "id"
        static let start_time = "start_time"
        static let end_time = "end_time"
        static let rsvp_status = "rsvp_status"
    }
    
    struct Facebook {
        static let user_age_range = "user_age_range"
    }
    
    struct imageHandling {
        static let jpg = "jpg"
        static let mp4 = "mp4"
        static let gif = "gif"
        static let image_url = "image_url"
        static let thumbnailProfileImage = "thumb-"
        static let smallProfileImage = "small-"
        static let mediumProfileImage = "medium-"
    }
    
    struct notification{
        static let showNotification = "showNotification"
        static let liveMatch = "liveMatchNotification"
        static let chatNotification = "chatNotification"
    }
    
}
