//
//  EventController.swift
//  Krown
//
//  Created by KrownUnity on 25/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import Foundation

class EventController {
    
    static let shared = EventController()
    
    var eventArray = [EventObject]()
    var attendingArray = [String]()
    
    func getEventArrayFromMatched(_ id: String, callback: @escaping ([EventObject]) -> Void) {
        
        WebServiceController.shared.getEvents(String(id), callback: {
            (response) in
            // Clear eventArray and reload
            self.eventArray.removeAll()
            self.eventGenerator(response["events"]! as! NSArray)
            callback(self.eventArray)
        })
        
    }
    func getMyEvents(_ callback: @escaping (MyEventsObject) -> Void) {
        
        WebServiceController.shared.getMyEvents({ (response) in
            callback(MyEventsObject.init(response))
        })
        
    }
    
    func getMyUpcomingEvents(per_page: Int,page_number:Int,_ callback: @escaping (MyEventsObject) -> Void) {
        WebServiceController.shared.getMyUpcomingEvents(per_page: per_page, page_number: page_number,{ (response) in
            callback(MyEventsObject.init(response))
        })
    }
    func getMySuggestedEvents(per_page: Int,page_number:Int,_ callback: @escaping (MyEventsObject) -> Void) {
        WebServiceController.shared.getMySuggestedEvents(per_page: per_page, page_number: page_number,{ (response) in
            callback(MyEventsObject.init(response))
        })
    }
    
    func getMyPastEvents(per_page: Int,page_number:Int,_ callback: @escaping (MyEventsObject) -> Void) {
        WebServiceController.shared.getMyPastEvents(per_page: per_page, page_number: page_number,{ (response) in
            callback(MyEventsObject.init(response))
        })
    }
    
    func getEventDetail(_ fb_event_id: String, callback: @escaping (EventsModel) -> Void) {
        
        WebServiceController.shared.getEventDetail(fb_event_id, callback: { (response) in
            if let eventDetails : NSArray = response["eventDetails"] as? NSArray {
                if let dict : [String : Any] = eventDetails[0] as? [String : Any] {
                    callback(EventsModel.init(dict))
                }
            }
        })
    }
    
    func eventGenerator(events: NSArray) -> ([EventObject]) {
        var eventObjects = [EventObject]()
        for index in 0..<events.count {
            
            let event: NSDictionary = events[index] as! NSDictionary
            let title: String = event["event_title"] as! String
            // if title is empty we will not show it
            if title.isEmpty {
                break
            }
            
            let timeStart: String = event["start_time"] as? String ?? ""
            let _: String = event["end_time"] as? String ?? "" // previously called timeEnd, canged to _ to silence the compiler
            let totalAttending: String = event["attending_count"] as! String
            let imageURL: String = event["cover_url"] as? String ?? ""
            let description: String = event["description"] as? String ?? ""
            let id: String = event["fb_event_id"] as! String
            let rsvpStatus: String = event["rsvp_status"] as? String ?? ""
            
            eventObjects.append(EventObject(timeStart: timeStart, title: title, totalAttending: totalAttending, imageURL: imageURL, description: description, id: id, attendingMatches: [MatchObject](), rsvpStatus: rsvpStatus))
            
        }
        return(eventObjects)
    }
    
    func eventGenerator(_ events: NSArray) {
        
        for index in 0..<events.count {
            let eventsDict: NSDictionary = events[index] as! NSDictionary
            let event = eventsDict["events"] as! NSDictionary
            let timeStart: String = event["start_time"] as? String ?? ""
            let _: String = event["end_time"] as? String ?? "" // previously called timeEnd, canged to _ to silence the compiler
            let title: String = event["event_title"] as? String ?? ""
            let totalAttending: String = event["attending_count"] as! String
            let imageURL: String = event["cover_url"] as? String ?? ""
            let description: String = event["description"] as? String ?? ""
            let id: String = event["fb_event_id"] as! String
            let rsvpStatus: String = event["rsvp_status"] as? String ?? ""
            
            var attendingMatches = [MatchObject]()
            if let attendingMatchArray = eventsDict["attendingMatches"] as? NSArray {
                let mainController = MainController()
                mainController.getEventAttendees(attendees: attendingMatchArray) { (attendeeArray) in
                    attendingMatches = attendeeArray
                }
            }
            
            eventArray.append(EventObject(timeStart: timeStart, title: title, totalAttending: totalAttending, imageURL: imageURL, description: description, id: id, attendingMatches: attendingMatches, rsvpStatus: rsvpStatus))
        }
        
    }
    
    
    func interestGenerator(interests: NSArray) -> ([InterestModel]) {
        var interestObjects = [InterestModel]()
        for index in 0..<interests.count {
            
            let interests: NSDictionary = interests[index] as! NSDictionary
            
            
            let interest: String = interests["interest"] as! String
            let common: String = interests["common"] as! String
            let interest_id: String = interests["interest_id"] as! String
            let member_id: String = interests["member_id"] as! String
            let isSelected: Bool = interests["isSelected"] as? Bool ?? true
           
            interestObjects.append(InterestModel(common: common, interest: interest, interest_id: interest_id, member_id: member_id, isSelected: isSelected))
            
        }
        return(interestObjects)
    }
    
}
