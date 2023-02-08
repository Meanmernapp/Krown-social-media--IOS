//
//  EventObject.swift
//  Krown
//
//  Created by KrownUnity on 25/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//
import UIKit

class EventObject {

    var timeStart: String
    var title: String
    var totalAttending: String
    var imageURL: String
    var description: String
    var id: String
    var attendingMatches: [MatchObject]?
    var rsvpStatus: String

    init ( timeStart: String, title: String, totalAttending: String, imageURL: String, description: String, id: String, attendingMatches: [MatchObject]?, rsvpStatus: String) {

        self.timeStart = timeStart
        self.title = title
        self.totalAttending = totalAttending
        self.imageURL = imageURL
        self.description = description
        self.id = id
        self.attendingMatches = attendingMatches!
        self.rsvpStatus = rsvpStatus
    }
}
