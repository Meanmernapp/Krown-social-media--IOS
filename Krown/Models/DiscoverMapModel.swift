//
//  DiscoverMapModel.swift
//  Krown
//
//  Created by Apple on 03/10/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
import UIKit


class POIModel : Codable {

    var errorCode: String?
    var locations: [POILocationModel?]
    
    
    enum CodingKeys: String, CodingKey {
        case locations
        case errorCode = "ErrorCode"
    }
    
    init (errorCode: String, locations: [POILocationModel]){
        self.errorCode = errorCode
        self.locations = locations
        
    }
}


class POILocationModel : Codable{
    let category, id, locationBackground, logoImageURL: String?
    let openingHoursFriFrom, openingHoursFriTo, openingHoursMonFrom, openingHoursMonTo: String?
    let openingHoursSatFrom, openingHoursSatTo, openingHoursSunFrom, openingHoursSunTo: String?
    let openingHoursThuFrom, openingHoursThuTo, openingHoursTueFrom, openingHoursTueTo: String?
    let openingHoursWedFrom, openingHoursWedTo, placeCity, placeCountry: String?
    let placeLatitude, placeLongitude, placeName, placeState: String?
    let placeStreet, placeZip, promotionalText: String?

    enum CodingKeys: String, CodingKey {
        case category, id
        case locationBackground = "location_background"
        case logoImageURL = "logo_image_url"
        case openingHoursFriFrom = "opening_hours_fri_from"
        case openingHoursFriTo = "opening_hours_fri_to"
        case openingHoursMonFrom = "opening_hours_mon_from"
        case openingHoursMonTo = "opening_hours_mon_to"
        case openingHoursSatFrom = "opening_hours_sat_from"
        case openingHoursSatTo = "opening_hours_sat_to"
        case openingHoursSunFrom = "opening_hours_sun_from"
        case openingHoursSunTo = "opening_hours_sun_to"
        case openingHoursThuFrom = "opening_hours_thu_from"
        case openingHoursThuTo = "opening_hours_thu_to"
        case openingHoursTueFrom = "opening_hours_tue_from"
        case openingHoursTueTo = "opening_hours_tue_to"
        case openingHoursWedFrom = "opening_hours_wed_from"
        case openingHoursWedTo = "opening_hours_wed_to"
        case placeCity = "place_city"
        case placeCountry = "place_country"
        case placeLatitude = "place_latitude"
        case placeLongitude = "place_longitude"
        case placeName = "place_name"
        case placeState = "place_state"
        case placeStreet = "place_street"
        case placeZip = "place_zip"
        case promotionalText = "promotional_text"
    }

    init(category: String, id: String, locationBackground: String, logoImageURL: String, openingHoursFriFrom: String, openingHoursFriTo: String, openingHoursMonFrom: String, openingHoursMonTo: String, openingHoursSatFrom: String, openingHoursSatTo: String, openingHoursSunFrom: String, openingHoursSunTo: String, openingHoursThuFrom: String, openingHoursThuTo: String, openingHoursTueFrom: String, openingHoursTueTo: String, openingHoursWedFrom: String, openingHoursWedTo: String, placeCity: String, placeCountry: String, placeLatitude: String, placeLongitude: String, placeName: String, placeState: String, placeStreet: String, placeZip: String, promotionalText: String) {
        self.category = category
        self.id = id
        self.locationBackground = locationBackground
        self.logoImageURL = logoImageURL
        self.openingHoursFriFrom = openingHoursFriFrom
        self.openingHoursFriTo = openingHoursFriTo
        self.openingHoursMonFrom = openingHoursMonFrom
        self.openingHoursMonTo = openingHoursMonTo
        self.openingHoursSatFrom = openingHoursSatFrom
        self.openingHoursSatTo = openingHoursSatTo
        self.openingHoursSunFrom = openingHoursSunFrom
        self.openingHoursSunTo = openingHoursSunTo
        self.openingHoursThuFrom = openingHoursThuFrom
        self.openingHoursThuTo = openingHoursThuTo
        self.openingHoursTueFrom = openingHoursTueFrom
        self.openingHoursTueTo = openingHoursTueTo
        self.openingHoursWedFrom = openingHoursWedFrom
        self.openingHoursWedTo = openingHoursWedTo
        self.placeCity = placeCity
        self.placeCountry = placeCountry
        self.placeLatitude = placeLatitude
        self.placeLongitude = placeLongitude
        self.placeName = placeName
        self.placeState = placeState
        self.placeStreet = placeStreet
        self.placeZip = placeZip
        self.promotionalText = promotionalText
    }
}
