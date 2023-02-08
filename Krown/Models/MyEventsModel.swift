//
//  MyEventsModel.swift
//  Krown
//
//  Created by macOS on 01/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI
import AVKit

func load(_ filename: String) -> MyEventsObject? {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    if let myEventsDict : [String : Any] = convertToDictionary(data: data)
    {
        return MyEventsObject.init(myEventsDict)
    }
    return nil
}

func sortArray(array : [[String:Any]]) -> [[String:Any]]{
  
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"


    let sorted = array.sorted {
         df.date(from: $0["created_at"] as? String ?? "" ) ?? Date() > df.date(from:  $1["created_at"] as? String ?? "") ?? Date()
        
    }
    //print(sorted)
    return sorted
}

func convertToDictionary(data: Data) -> [String: Any]? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
        //print(error.localizedDescription)
    }
    return nil
}

class MyEventsObject: NSObject, Codable, NSCopying, NSCoding, Identifiable {
    
    enum Keys: String {
        case with
        case pastEvents
        case suggestedEvents
        case upcomingEvents
    }
    var pastEvents: [EventsModel]?
    var suggestedEvents: [EventsModel]?
    var upcomingEvents: [EventsModel]?
    var with : MyEventsWithModel?
    init(_ dict:[String:Any]) {
        if let eventsArray = dict[Keys.pastEvents.rawValue] as? [[String:Any]] {
            //            self.pastEvents = eventsArray.map({ MyEventsModel($0) })
            ////            let pastEventsCopy = self.pastEvents
            self.pastEvents = eventsArray.map({ EventsModel($0) }).sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedDescending })
        }
        if let eventsArray = dict[Keys.suggestedEvents.rawValue] as? [[String:Any]] {
            //            self.suggestedEvents = eventsArray[0].map({ EventsModel($0) })
            //
            self.suggestedEvents = eventsArray.map({ EventsModel($0) }).sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedAscending })
        }
        if let eventsArray = dict[Keys.upcomingEvents.rawValue] as? [[String:Any]] {
            //            self.upcomingEvents = eventsArray.map({ EventsModel($0) })
            self.upcomingEvents = eventsArray.map({ EventsModel($0) }).sorted(by: { $0.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").compare($1.events?.start_time?.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ") ?? Date()) == .orderedAscending })
        }
        if let withDict = dict[Keys.with.rawValue] as? [String:Any] {
            self.with = MyEventsWithModel.init(withDict)
        }
    }
    
    required init?(coder: NSCoder) {
        self.pastEvents = coder.decodeObject(forKey: Keys.pastEvents.rawValue) as? [EventsModel]
        self.suggestedEvents = coder.decodeObject(forKey: Keys.suggestedEvents.rawValue) as? [EventsModel]
        self.upcomingEvents = coder.decodeObject(forKey: Keys.upcomingEvents.rawValue) as? [EventsModel]
        self.with = coder.decodeObject(forKey: Keys.with.rawValue) as? MyEventsWithModel
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MyEventsObject([:])
        copy.pastEvents = self.pastEvents
        copy.suggestedEvents = self.suggestedEvents
        copy.upcomingEvents = self.upcomingEvents
        copy.with = self.with
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.pastEvents, forKey: Keys.pastEvents.rawValue)
        coder.encode(self.suggestedEvents, forKey: Keys.suggestedEvents.rawValue)
        coder.encode(self.upcomingEvents, forKey: Keys.upcomingEvents.rawValue)
        coder.encode(self.with, forKey: Keys.with.rawValue)
    }
    
}
class EventsModel: NSObject, Codable, NSCopying, NSCoding, Identifiable  {
    
    enum Keys: String {
        case events
        case attendingMatches
        case notAttendingMatches
    }
    var events: MyEventsModel?
    var attendingMatches: [MatchesModel]?
    var notAttendingMatches: [MatchesModel]?
    
    init(_ dict:[String:Any]) {
        if let eventsDict = dict[Keys.events.rawValue] as? [String:Any] {
            self.events = MyEventsModel.init(eventsDict)
        }
        if let matchesArray = dict[Keys.attendingMatches.rawValue] as? NSArray {
            var filterArr : [[String:Any]] = [[String:Any]]()
            for i in 0..<matchesArray.count {
                if let arr : [String:Any] = matchesArray.object(at: i) as? [String:Any] {
                    filterArr.append(arr)
                }
            }
//            self.attendingMatches = matchesArray.map({ MatchesModel($0) })
            self.attendingMatches = filterArr.map({ MatchesModel($0) })
        }
        if let matchesArray = dict[Keys.notAttendingMatches.rawValue] as? NSArray {
            var filterArr : [[String:Any]] = [[String:Any]]()
            for i in 0..<matchesArray.count {
                if let arr : [String:Any] = matchesArray.object(at: i) as? [String:Any] {
                    filterArr.append(arr)
                }
            }
            self.notAttendingMatches = filterArr.map({ MatchesModel($0) })
        }
        
    }
    required init?(coder: NSCoder) {
        self.events = coder.decodeObject(forKey: Keys.events.rawValue) as? MyEventsModel
        self.attendingMatches = coder.decodeObject(forKey: Keys.attendingMatches.rawValue) as? [MatchesModel]
        self.notAttendingMatches = coder.decodeObject(forKey: Keys.notAttendingMatches.rawValue) as? [MatchesModel]
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = EventsModel([:])
        copy.events = self.events
        copy.attendingMatches = self.attendingMatches
        copy.notAttendingMatches = self.notAttendingMatches
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.events, forKey: Keys.events.rawValue)
        coder.encode(self.attendingMatches, forKey: Keys.attendingMatches.rawValue)
        coder.encode(self.notAttendingMatches, forKey: Keys.notAttendingMatches.rawValue)
    }
    
}
class MyEventsWithModel: NSObject, Codable, NSCopying, NSCoding, Identifiable  {
    
    
    enum Keys: String {
        case total
        case per_page
        case page_number
        
    }
    var total : String?
    var per_page : String?
    var page_number : String?
    
    init(_ dict:[String:Any]) {
        total = checkForString(dict, key : Keys.total.rawValue)
        per_page = checkForString(dict, key : Keys.per_page.rawValue)
        page_number = checkForString(dict, key : Keys.page_number.rawValue)
        
    }
    required init?(coder: NSCoder) {
        self.total = coder.decodeObject(forKey: Keys.total.rawValue) as? String
        self.per_page = coder.decodeObject(forKey: Keys.per_page.rawValue) as? String
        self.page_number = coder.decodeObject(forKey: Keys.page_number.rawValue) as? String
    }
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MyEventsWithModel([:])
        copy.total = self.total
        copy.per_page = self.per_page
        copy.page_number = self.page_number
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.total, forKey: Keys.total.rawValue)
        coder.encode(self.per_page, forKey: Keys.per_page.rawValue)
        coder.encode(self.page_number, forKey: Keys.page_number.rawValue)
    }
}

class MyEventsModel: NSObject, Codable, NSCopying, NSCoding, Identifiable  {
    
    enum Keys: String {
        case id
        case created_at
        case updated_at
        case fb_event_id
        case type
        case attending_count
        case start_time
        case end_time
        case place_name
        case place_city
        case place_country
        case place_state
        case place_street
        case place_zip
        case place_latitude
        case place_longitude
        case event_title
        case desc = "description"
        case cover_url
        case boost
        case member_id
        case rsvp_status
        case matchCount
    }
    
    var id: String?
    var created_at: String?
    var updated_at: String?
    var fb_event_id: String?
    var type: String?
    var attending_count: String?
    var start_time: String?
    var end_time: String?
    var place_name: String?
    var place_city: String?
    var place_country: String?
    var place_state: String?
    var place_street: String?
    var place_zip: String?
    var place_latitude: String?
    var place_longitude: String?
    var event_title: String?
    var desc: String?
    var cover_url: String?
    var boost: String?
    var member_id: String?
    var rsvp_status: String?
    var matchCount: String?
    
    init(_ dict:[String:Any]) {
        id = checkForString(dict, key : Keys.id.rawValue)
        created_at = checkForString(dict, key : Keys.created_at.rawValue)
        updated_at = checkForString(dict, key : Keys.updated_at.rawValue)
        fb_event_id = checkForString(dict, key : Keys.fb_event_id.rawValue)
        type = checkForString(dict, key : Keys.type.rawValue)
        attending_count = checkForString(dict, key : Keys.attending_count.rawValue)
        start_time = checkForString(dict, key : Keys.start_time.rawValue)
        end_time = checkForString(dict, key : Keys.end_time.rawValue)
        place_name = checkForString(dict, key : Keys.place_name.rawValue)
        place_city = checkForString(dict, key : Keys.place_city.rawValue)
        place_country = checkForString(dict, key : Keys.place_country.rawValue)
        place_state = checkForString(dict, key : Keys.place_state.rawValue)
        place_street = checkForString(dict, key : Keys.place_street.rawValue)
        place_zip = checkForString(dict, key : Keys.place_zip.rawValue)
        place_latitude = checkForString(dict, key : Keys.place_latitude.rawValue)
        place_longitude = checkForString(dict, key : Keys.place_longitude.rawValue)
        event_title = checkForString(dict, key : Keys.event_title.rawValue)
        desc = checkForString(dict, key : Keys.desc.rawValue)
        cover_url = checkForString(dict, key : Keys.cover_url.rawValue)
        boost = checkForString(dict, key : Keys.boost.rawValue)
        member_id = checkForString(dict, key : Keys.member_id.rawValue)
        rsvp_status = checkForString(dict, key : Keys.rsvp_status.rawValue)
        matchCount = checkForString(dict, key : Keys.matchCount.rawValue)
    }
    required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: Keys.id.rawValue) as? String
        self.created_at = coder.decodeObject(forKey: Keys.created_at.rawValue) as? String
        self.updated_at = coder.decodeObject(forKey: Keys.updated_at.rawValue) as? String
        self.fb_event_id = coder.decodeObject(forKey: Keys.fb_event_id.rawValue) as? String
        self.type = coder.decodeObject(forKey: Keys.type.rawValue) as? String
        self.attending_count = coder.decodeObject(forKey: Keys.attending_count.rawValue) as? String
        self.start_time = coder.decodeObject(forKey: Keys.start_time.rawValue) as? String
        self.end_time = coder.decodeObject(forKey: Keys.end_time.rawValue) as? String
        self.place_name = coder.decodeObject(forKey: Keys.place_name.rawValue) as? String
        self.place_city = coder.decodeObject(forKey: Keys.place_city.rawValue) as? String
        self.place_country = coder.decodeObject(forKey: Keys.place_country.rawValue) as? String
        self.place_state = coder.decodeObject(forKey: Keys.place_state.rawValue) as? String
        self.place_street = coder.decodeObject(forKey: Keys.place_street.rawValue) as? String
        self.place_zip = coder.decodeObject(forKey: Keys.place_zip.rawValue) as? String
        self.place_latitude = coder.decodeObject(forKey: Keys.place_latitude.rawValue) as? String
        self.place_longitude = coder.decodeObject(forKey: Keys.place_longitude.rawValue) as? String
        self.event_title = coder.decodeObject(forKey: Keys.event_title.rawValue) as? String
        self.desc = coder.decodeObject(forKey: Keys.desc.rawValue) as? String
        self.cover_url = coder.decodeObject(forKey: Keys.cover_url.rawValue) as? String
        self.boost = coder.decodeObject(forKey: Keys.boost.rawValue) as? String
        self.member_id = coder.decodeObject(forKey: Keys.member_id.rawValue) as? String
        self.rsvp_status = coder.decodeObject(forKey: Keys.rsvp_status.rawValue) as? String
        self.matchCount = coder.decodeObject(forKey: Keys.matchCount.rawValue) as? String
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MyEventsModel([:])
        copy.id = self.id
        copy.created_at = self.created_at
        copy.updated_at = self.updated_at
        copy.fb_event_id = self.fb_event_id
        copy.type = self.type
        copy.attending_count = self.attending_count
        copy.start_time = self.start_time
        copy.end_time = self.end_time
        copy.place_name = self.place_name
        copy.place_city = self.place_city
        copy.place_country = self.place_country
        copy.place_state = self.place_state
        copy.place_street = self.place_street
        copy.place_zip = self.place_zip
        copy.place_latitude = self.place_latitude
        copy.place_longitude = self.place_longitude
        copy.event_title = self.event_title
        copy.desc = self.desc
        copy.cover_url = self.cover_url
        copy.boost = self.boost
        copy.member_id = self.member_id
        copy.rsvp_status = self.rsvp_status
        copy.matchCount = self.matchCount
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: Keys.id.rawValue)
        coder.encode(self.created_at, forKey: Keys.created_at.rawValue)
        coder.encode(self.updated_at, forKey: Keys.updated_at.rawValue)
        coder.encode(self.fb_event_id, forKey: Keys.fb_event_id.rawValue)
        coder.encode(self.type, forKey: Keys.type.rawValue)
        coder.encode(self.attending_count, forKey: Keys.attending_count.rawValue)
        coder.encode(self.start_time, forKey: Keys.start_time.rawValue)
        coder.encode(self.end_time, forKey: Keys.end_time.rawValue)
        coder.encode(self.place_name, forKey: Keys.place_name.rawValue)
        coder.encode(self.place_city, forKey: Keys.place_city.rawValue)
        coder.encode(self.place_country, forKey: Keys.place_country.rawValue)
        coder.encode(self.place_state, forKey: Keys.place_state.rawValue)
        coder.encode(self.place_street, forKey: Keys.place_street.rawValue)
        coder.encode(self.place_zip, forKey: Keys.place_zip.rawValue)
        coder.encode(self.place_latitude, forKey: Keys.place_latitude.rawValue)
        coder.encode(self.place_longitude, forKey: Keys.place_longitude.rawValue)
        coder.encode(self.event_title, forKey: Keys.event_title.rawValue)
        coder.encode(self.desc, forKey: Keys.desc.rawValue)
        coder.encode(self.cover_url, forKey: Keys.cover_url.rawValue)
        coder.encode(self.boost, forKey: Keys.boost.rawValue)
        coder.encode(self.member_id, forKey: Keys.member_id.rawValue)
        coder.encode(self.rsvp_status, forKey: Keys.rsvp_status.rawValue)
        coder.encode(self.matchCount, forKey: Keys.matchCount.rawValue)
    }
    
}

