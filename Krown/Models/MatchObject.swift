//
//  MatchObject.swift
//  Krown
//
//  Created by KrownUnity on 17/10/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit

class MatchObject {
    var id: String
    var name: String
    var imageArray: [String] = []
    var lastActiveTime: String
    var distance: String
    var messageHistory: [MessageObject]?
    var interests: [InterestModel]?
   
    init (id: String, name: String, imageArray: [String], lastActiveTime: String, distance: String, messageHistory: [MessageObject]? = nil, interests: [InterestModel]?) {
        self.id = id
        self.name = name
        self.imageArray = imageArray
        self.lastActiveTime = lastActiveTime
        self.messageHistory = messageHistory
        self.distance = distance
        self.interests = interests
    }
    convenience init() {
        self.init(id: "", name: "", imageArray: [String()], lastActiveTime: "", distance: "0", interests:[InterestModel]())
    }

}
class MatchObjectModel: NSObject, Codable, NSCopying, NSCoding, Identifiable  {
    
    enum Keys: String {
        case id
        case name
        case imageArray
        case lastActiveTime
        case distance
    }
        
    var id: String?
    var name: String?
    var imageArray: [String]?
    var lastActiveTime: String?
    var distance: String?

    init(_ dict:[String:Any]) {
        id = checkForString(dict, key : Keys.id.rawValue)
        name = checkForString(dict, key : Keys.name.rawValue)
        imageArray = dict[Keys.imageArray.rawValue] as? [String] ?? [""]
        lastActiveTime = checkForString(dict, key : Keys.lastActiveTime.rawValue)
        distance = checkForString(dict, key : Keys.distance.rawValue)
    }
    required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: Keys.id.rawValue) as? String
        self.name = coder.decodeObject(forKey: Keys.name.rawValue) as? String
        self.imageArray = coder.decodeObject(forKey: Keys.imageArray.rawValue) as? [String]
        self.lastActiveTime = coder.decodeObject(forKey: Keys.lastActiveTime.rawValue) as? String
        self.distance = coder.decodeObject(forKey: Keys.distance.rawValue) as? String
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MatchObjectModel([:])
        copy.id = self.id
        copy.name = self.name
        copy.imageArray = self.imageArray
        copy.lastActiveTime = self.lastActiveTime
        copy.distance = self.distance
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: Keys.id.rawValue)
        coder.encode(self.name, forKey: Keys.name.rawValue)
        coder.encode(self.imageArray, forKey: Keys.imageArray.rawValue)
        coder.encode(self.lastActiveTime, forKey: Keys.lastActiveTime.rawValue)
        coder.encode(self.distance, forKey: Keys.distance.rawValue)
    }

}
