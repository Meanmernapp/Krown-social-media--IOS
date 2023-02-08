//
//  PersonObject.swift
//  Krown
//
//  Created by KrownUnity on 25/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//
import UIKit
import Foundation
import SwiftUI

class PersonObject: ObservableObject {
    @Published var id: String
    @Published var name: String
    @Published var distance: String
    @Published var age: String
    @Published var status: String
    @Published var employment: String
    @Published var position: String
    @Published var school: String
    @Published var concentration: String
    @Published var interests: [InterestModel]
    @Published var imageArray: [String] = []
    @Published var events: [EventObject]
    @Published var email: String
    @Published var phone_number: String
    @Published var occupation: String
    @Published var education: String
    @Published var matched: String
    
    init (id: String, name: String, distance: String, age: String, status: String, employment: String, school: String, concentration: String, position: String, interests: [InterestModel], imageArray: [String], events: [EventObject], email: String, phone_number: String, matched : String? = "") {
        self.id = id
        self.name = name
        self.distance = distance
        self.age = age
        self.status = status
        self.employment = employment
        self.school = school
        self.concentration = concentration
        self.position = position
        self.interests = interests
        self.imageArray = imageArray
        self.events = events
        self.email = email
        self.phone_number = phone_number
        self.occupation = employment + " - " + position
        self.matched = matched ?? ""
        if employment.count == 0 && position.count == 0 {
            self.occupation = " - "
        } else if employment.count == 0 && position.count > 0 {
            self.occupation = position
        } else if employment.count > 0 && position.count == 0 {
            self.occupation = employment
        }
        
        self.education = school + " - " + concentration
        if school.count == 0 && concentration.count == 0 {
            self.education = ""
        } else if school.count == 0 && concentration.count > 0 {
            self.education = concentration
        } else if school.count > 0 && concentration.count == 0 {
            self.education = school
        }
        
    }
    convenience init() {
        self.init(id: "", name: "", distance: "", age: "", status: "", employment: "", school: "", concentration: "", position: "", interests: [InterestModel](), imageArray: [String](), events: [EventObject](), email: "", phone_number: "", matched : "")
    }
    
    
    func getUserDetails(userID: String){
        let main = MainController()
        
        main.distributeMatch(userID) { profile in
            
            self.id = profile.id
            self.name = profile.name
            self.distance = profile.distance
            self.age = profile.age
            self.status = profile.status
            self.employment = profile.employment
            self.school = profile.school
            self.concentration = profile.concentration
            self.position = profile.position
            self.interests = profile.interests
            self.imageArray = profile.imageArray
            self.events = profile.events
            self.email = profile.email
            self.phone_number = profile.phone_number
            self.matched = profile.matched
            
            self.occupation = profile.employment + " - " + profile.position
            if profile.employment.count == 0 && profile.position.count == 0 {
                self.occupation = ""
            } else if profile.employment.count == 0 && profile.position.count > 0 {
                self.occupation = profile.position
            } else if profile.employment.count > 0 && profile.position.count == 0 {
                self.occupation = profile.employment
            }
            
            self.education = profile.school + " - " + profile.concentration
            if profile.school.count == 0 && profile.concentration.count == 0 {
                self.education = ""
            } else if profile.school.count == 0 && profile.concentration.count > 0 {
                self.education = profile.concentration
            } else if profile.school.count > 0 && profile.concentration.count == 0 {
                self.education = profile.school
            }
        }
    }
    
 }
