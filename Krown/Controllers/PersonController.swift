//
//  PersonController.swift
//  Krown
//
//  Created by KrownUnity on 25/08/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PersonController {
    static var shared = PersonController()

    var swipeArray = [PersonObject]()
    var matchArray = [MatchObject]()
    var waveArray = [MatchObject]()
    var arrWaveModel = [MatchesModel]()
    
    func getMatchArray(_ id: String, webService: WebServiceController, callback: @escaping ([[MatchObject]]) -> Void) {
        
        webService.getMatches(String(id), callback: {
            (response) in
            if response["likes"] != nil {
                if let likes : NSArray = response["likes"] as? NSArray {
                    self.matchArray.removeAll()
                    self.matchGenerator(likes)
                }
                if let waves : NSArray = response["waves"] as? NSArray {
                    self.waveArray.removeAll()
                    self.waveGenerator(waves)
                }
                callback([self.matchArray,self.waveArray])
            } else {
                let emptyMatchArray = [MatchObject]()
                callback([emptyMatchArray,emptyMatchArray])
            }
        })
        
    }
    
    func getWaveModelArray(_ id: String, webService: WebServiceController, callback: @escaping ([MatchesModel]) -> Void){
        webService.getMatches(String(id), callback: {
            (response) in
            if response["waves"] != nil {
            
                if let waves : NSArray = response["waves"] as? NSArray {
                    self.arrWaveModel.removeAll()
                    var arr : [MatchesModel] = [MatchesModel]()
                    for i in 0..<waves.count {
                        if let dict : [String : Any] = waves.object(at: i) as? [String : Any] {
                            arr.append(MatchesModel.init(dict))
                        }
                    }
                    self.arrWaveModel = arr
                }
                callback(self.arrWaveModel)
            } else {
                let emptyMatchArray = [MatchesModel]()
                callback(emptyMatchArray)
            }
        })
    }
    
    func getMatchChatArray(_ id: String, webService: WebServiceController, callback: @escaping ([MatchesModel]) -> Void) {
        
        webService.getMatches(String(id), callback: {
            (response) in
            if response["likes"] != nil {
                var arr : [MatchesModel] = [MatchesModel]()
                if let likes : NSArray = response["likes"] as? NSArray {
                    for i in 0..<likes.count {
                        if let dict : [String : Any] = likes.object(at: i) as? [String : Any] {
                            arr.append(MatchesModel.init(dict))
                        }
                    }
                }
                callback(arr)
            } else {
                let arr : [MatchesModel] = [MatchesModel]()
                callback(arr)
            }
        })
        
    }

    func getEventAttendees(attendingMatches: NSArray, callback: @escaping ([MatchObject]) -> Void) {
        matchGenerator(attendingMatches)
        callback(matchArray)
    }
    
    func getSwipeArray(_ id: String, webService: WebServiceController, callback: @escaping ([PersonObject]) -> Void) {
        
        // reset swipearray so the data does not get appended
        self.swipeArray = [PersonObject]()
        webService.getSwipes(String(id), callback: {
            (response) in
            
            if let matches = response["matches"] as? NSArray { // Failsafe for when no matches left
                
                self.personGenerator(matches)
                //print("Swipes found with current settings")
                callback(self.swipeArray)
                
            } else {
                //print("No swipes found with current settings")
                callback(self.swipeArray)
            }
        })
        
    }
    
    func getListPeopleViewProfile( profileArray : [MatchesModel], callback: @escaping ([PersonObject]) -> Void){
        self.swipeArray = [PersonObject]()
        profileArray.forEach{ profile in

            
            let interestDict = profile.interests ?? []
            let id: String = profile.id ?? ""
            let name: String = profile.first_name ?? ""
            let distance: String = profile.distance ?? ""
            
            let status: String = profile.status ?? ""
            let employment: String = profile.employer ?? ""
            let position: String = profile.position ?? ""
            let school: String = profile.school  ?? ""
            let concentration: String = profile.concentration  ?? ""
            let email: String = profile.email ?? ""
            var imageArray = [String]()
            let profile_pic_urlArray = profile.profile_pic_url ?? []
            let matched = profile.matched
            for imageUrlAny in profile_pic_urlArray {
                let imageUrlDict = imageUrlAny.image_url
                let imageUrl = imageUrlDict
                imageArray.append(imageUrl ?? "")
            }
            var interests: [InterestModel] = [] //eventController.interestGenerator(interests:  interestArray as NSArray)
            
            for index in 0..<interestDict.count {
          
                let dict = interestDict[index]
                let interest: String = dict.interest ?? ""
                let common: String = dict.common ?? ""
                let interest_id: String = dict.interest_id ?? ""
                let member_id: String = dict.member_id ?? ""
                let isSelected: Bool = dict.isSelected ?? false
               
                interests.append(InterestModel(common: common, interest: interest, interest_id: interest_id, member_id: member_id, isSelected: isSelected))
                
            }
            
            
            let personDict = PersonObject(id: id, name: name, distance: distance, age: "", status: status, employment: employment, school: school, concentration: concentration, position: position, interests: interests, imageArray: imageArray, events: [], email: email, phone_number: "", matched: matched )
            
            swipeArray.append(personDict)
            
        }
        
        callback(swipeArray)
    }
    
    func getProfile(_ id: String, webService: WebServiceController, callback: @escaping (PersonObject) -> Void) {
        webService.getProfile(String(id)) { (profile) in
            self.personGenerator(profile, callback: { (person) in
                callback(person)
            })
        }
        
    }
    
    func personGenerator(_ profile: NSDictionary, callback: (PersonObject) -> Void) {
        let person = profile["entity_details"]! as! NSDictionary
        let eventsDict = person["common_events"]! as! NSArray
        let interestDict = person[WebKeyhandler.User.interests]! as! NSArray
        let id: String = person["id"] as! String
        let name: String = person["first_name"] as! String
        let distance: String = person["distance"] as? String ?? "0"
        let age: String = person["age"] as? String ?? ""
        let status: String = person["status"] as? String ?? ""
        let employment: String = person["employer"] as? String ?? ""
        let position: String = person["position"] as? String ?? ""
        let school: String = person["school"] as? String ?? ""
        let concentration: String = person["concentration"] as? String ?? ""
        let email: String = person["email"] as? String ?? ""
        let phone_number: String = person["phone_number"] as? String ?? ""
        var imageArray = [String]()
        let profile_pic_urlArray = person[WebKeyhandler.User.profilePic] as! NSArray
        for imageUrlAny in profile_pic_urlArray {
            let imageUrlDict = imageUrlAny as! NSDictionary
            let imageUrl = imageUrlDict["image_url"] as! String
            imageArray.append(imageUrl)
        }
        // Potential error w/events
        let eventsArray: [EventObject]  = eventsDict as! [EventObject]
        let events: [EventObject] = EventController.shared.eventGenerator(events: eventsArray as NSArray)
        let interestArray: [InterestModel]  = interestDict as! [InterestModel]
        let interests: [InterestModel] = EventController.shared.interestGenerator(interests:  interestArray as NSArray)
        callback(PersonObject(id: id, name: name, distance: distance, age: age, status: status, employment: employment, school: school, concentration: concentration, position: position, interests: interests, imageArray: imageArray, events: events, email: email, phone_number: phone_number))
    }
    
    func personGenerator(_ swipes: NSArray) {
        for index in 0...swipes.count-1 {
            let swip: NSDictionary = swipes[index] as! NSDictionary

            
            //Potential trouble that needs to be tested
            let id: String = swip["id"]! as! String
            let name: String = swip["firstName"]! as! String
            let age: String = swip["age"]! as! String
            let distance: String = swip["distance"] as! String
            let status: String = swip["status"] as? String ?? ""
            let employment: String = swip["employer"]! as? String ?? ""
            let position: String = swip["position"] as? String ?? ""
            let school: String = swip["school"]! as? String ?? ""
            let concentration: String = swip["concentration"]! as? String ?? ""
            let imageArray: [String] = swip[WebKeyhandler.User.profilePic]! as! [String]
            let eventsArray: NSArray = swip["events"]! as! NSArray
            let interestArray: NSArray = swip[WebKeyhandler.User.interests]! as! NSArray
            let email: String = swip["email"] as? String ?? ""
            let phone_number: String = swip["phone_number"] as? String ?? ""
            let events: [EventObject] = EventController.shared.eventGenerator(events: eventsArray)
            let interests: [InterestModel] = EventController.shared.interestGenerator(interests: interestArray)
            swipeArray.append(PersonObject(id: id, name: name, distance: distance, age: age, status: status, employment: employment, school: school, concentration: concentration, position: position, interests: interests, imageArray: imageArray, events: events, email: email, phone_number: phone_number))
        }
        
    }
    
    func matchGenerator(_ matches: NSArray) {
        
        let group = DispatchGroup()
        for index in 0..<matches.count {
            
            let match: NSDictionary = matches[index] as! NSDictionary
            let id: String = match["id"]! as! String
            let name: String = match["first_name"]! as! String
            var imageArray = [String]()
            let profile_pic_urlArray = match[WebKeyhandler.User.profilePic] as! NSArray
            for imageUrlAny in profile_pic_urlArray {
                let imageUrlDict = imageUrlAny as! NSDictionary
                let imageUrl = imageUrlDict["image_url"] as! String
                imageArray.append(imageUrl)
            }
         
            let distance: String = match["distance"] as? String ?? "0"
            let lastActiveTime: String = match["last_active"]! as! String
            let jid = "krownuser_\(id)@" + URLHandler.xmpp_domain
            let sender = OneChat.sharedInstance.xmppLastActivity
            self.matchArray.append(MatchObject(id: id, name: name, imageArray: imageArray, lastActiveTime: lastActiveTime, distance: distance, interests: [InterestModel]()))
            
            //group.enter()
            OneLastActivity.sendLastActivityQueryToJID(userName: jid, sender: sender) {(response, _ , error) in
               /* if error == nil{
                    group.leave()
                }*/
            }
            
        }
        group.notify(queue: .main) {
            //Debugging for match array
            /*print("Main queue notified")
             for item in self.matchArray {
             print("matchArray element \(item.name) with the id \(item.id)  last activity is \(item.lastActiveTime)")
             }*/
        }
    }
    func waveGenerator(_ matches: NSArray) {
        for index in 0..<matches.count {
            let match: NSDictionary = matches[index] as! NSDictionary
            let id: String = match["id"]! as! String
            let name: String = match["first_name"]! as! String
            var imageArray = [String]()
            let profile_pic_urlArray = match[WebKeyhandler.User.profilePic] as! NSArray
            for imageUrlAny in profile_pic_urlArray {
                let imageUrlDict = imageUrlAny as! NSDictionary
                let imageUrl = imageUrlDict["image_url"] as! String
                imageArray.append(imageUrl)
            }
            // If there are empty values in received array from webservice below line is filtering that out
            imageArray = imageArray.filter { $0 != "" }
            var interests = [InterestModel]() //= match[WebKeyhandler.User.interests] as? [InterestModel]
            if let interestArray = match[WebKeyhandler.User.interests] as? [[String:Any]] {
                 interests = interestArray.map({ InterestModel($0) })
            }
            let distance: String = match["distance"] as? String ?? "0"
            let lastActiveTime: String = match["last_active"]! as! String
            self.waveArray.append(MatchObject(id: id, name: name, imageArray: imageArray, lastActiveTime: lastActiveTime, distance: distance, interests: interests))
        }
    }

    func matchObjectArray(_ matchArray: NSArray, callback: ([MatchesModel]) -> Void){
        var matchesObjectArray = [MatchesModel]()
        for match in matchArray {
            let matchDict = match as! [String:Any]
            let matchModel = MatchesModel.init(matchDict)
            matchesObjectArray.append(matchModel)
        }
        callback(matchesObjectArray)
    }
    
    func match(_ matchDict: NSDictionary, callback: (MatchObject) -> Void) {
        let match = matchDict["match"]! as! NSDictionary
        let id: String = String(describing: match["id"]!)
        let name: String = match["first_name"]! as! String
        var imageArray = [String]()
        let profile_pic_urlArray = match[WebKeyhandler.User.profilePic] as! NSArray
        for imageUrlAny in profile_pic_urlArray {
            let imageUrlDict = imageUrlAny as! NSDictionary
            let imageUrl = imageUrlDict["image_url"] as! String
            imageArray.append(imageUrl)
        }
        let lastActiveTime: String = match["last_active"]! as! String
        let distance: String = match["distance"] as? String ?? "0"

        let jid = "krownuser_\(id)@" + URLHandler.xmpp_domain
        let sender = OneChat.sharedInstance.xmppLastActivity
        
        OneLastActivity.sendLastActivityQueryToJID(userName: jid, sender: sender) {(response, _, _) in
            
            if response != nil {
            }
        }
        
        // we need a list of commen events
        callback(MatchObject(id: id, name: name, imageArray: imageArray, lastActiveTime: lastActiveTime, distance: distance, interests: [InterestModel]()))
        
    }
    
}
