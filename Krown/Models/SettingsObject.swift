//
//  SettingsObject.swift
//  Krown
//
//  Created by macOS on 29/12/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import Foundation
import UIKit

class SettingsObject: NSObject, Codable, NSCopying, NSCoding  {
    
    enum Keys: String {
        case id
        case created_at
        case updated_at
        case notification_mail
        case notification_mail_announcements
        case notification_mail_likes
        case notification_mail_matches
        case notification_mail_messages
        case notification_mail_promotions
        case notification_push
        case notification_push_announcements
        case notification_push_likes
        case notification_push_matches
        case notification_push_messages
        case notification_push_promotions
    }
    var id: String?
    var created_at: String?
    var updated_at: String?
    var notification_mail: String?
    var notification_mail_announcements: String?
    var notification_mail_likes: String?
    var notification_mail_matches: String?
    var notification_mail_messages: String?
    var notification_mail_promotions: String?
    var notification_push: String?
    var notification_push_announcements: String?
    var notification_push_likes: String?
    var notification_push_matches: String?
    var notification_push_messages: String?
    var notification_push_promotions: String?
    
    init(_ dict:[String:Any]) {
        id = checkForString(dict, key : Keys.id.rawValue)
        created_at = checkForString(dict, key : Keys.created_at.rawValue)
        updated_at = checkForString(dict, key : Keys.updated_at.rawValue)

        notification_mail = checkForString(dict, key : Keys.notification_mail.rawValue)
        notification_mail_announcements = checkForString(dict, key : Keys.notification_mail_announcements.rawValue)
        notification_mail_likes = checkForString(dict, key : Keys.notification_mail_likes.rawValue)
        notification_mail_matches = checkForString(dict, key : Keys.notification_mail_matches.rawValue)
        notification_mail_messages = checkForString(dict, key : Keys.notification_mail_messages.rawValue)
        notification_mail_promotions = checkForString(dict, key : Keys.notification_mail_promotions.rawValue)
        notification_push = checkForString(dict, key : Keys.notification_push.rawValue)
        notification_push_announcements = checkForString(dict, key : Keys.notification_push_announcements.rawValue)
        notification_push_likes = checkForString(dict, key : Keys.notification_push_likes.rawValue)
        notification_push_matches = checkForString(dict, key : Keys.notification_push_matches.rawValue)
        notification_push_messages = checkForString(dict, key : Keys.notification_push_messages.rawValue)
        notification_push_promotions = checkForString(dict, key : Keys.notification_push_promotions.rawValue)
    }
    required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: Keys.id.rawValue) as? String
        self.created_at = coder.decodeObject(forKey: Keys.created_at.rawValue) as? String
        self.updated_at = coder.decodeObject(forKey: Keys.updated_at.rawValue) as? String

        self.notification_mail = coder.decodeObject(forKey: Keys.notification_mail.rawValue) as? String
        self.notification_mail_announcements = coder.decodeObject(forKey: Keys.notification_mail_announcements.rawValue) as? String
        self.notification_mail_likes = coder.decodeObject(forKey: Keys.notification_mail_likes.rawValue) as? String
        self.notification_mail_matches = coder.decodeObject(forKey: Keys.notification_mail_matches.rawValue) as? String
        self.notification_mail_messages = coder.decodeObject(forKey: Keys.notification_mail_messages.rawValue) as? String
        self.notification_mail_promotions = coder.decodeObject(forKey: Keys.notification_mail_promotions.rawValue) as? String
        self.notification_push = coder.decodeObject(forKey: Keys.notification_push.rawValue) as? String
        self.notification_push_announcements = coder.decodeObject(forKey: Keys.notification_push_announcements.rawValue) as? String
        self.notification_push_likes = coder.decodeObject(forKey: Keys.notification_push_likes.rawValue) as? String
        self.notification_push_matches = coder.decodeObject(forKey: Keys.notification_push_matches.rawValue) as? String
        self.notification_push_messages = coder.decodeObject(forKey: Keys.notification_push_messages.rawValue) as? String
        self.notification_push_promotions = coder.decodeObject(forKey: Keys.notification_push_promotions.rawValue) as? String
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SettingsObject([:])
        copy.id = self.id
        copy.created_at = self.created_at
        copy.updated_at = self.updated_at
        copy.notification_mail = self.notification_mail
        copy.notification_mail_announcements = self.notification_mail_announcements
        copy.notification_mail_likes = self.notification_mail_likes
        copy.notification_mail_matches = self.notification_mail_matches
        copy.notification_mail_messages = self.notification_mail_messages
        copy.notification_mail_promotions = self.notification_mail_promotions
        copy.notification_push = self.notification_push
        copy.notification_push_announcements = self.notification_push_announcements
        copy.notification_push_likes = self.notification_push_likes
        copy.notification_push_matches = self.notification_push_matches
        copy.notification_push_messages = self.notification_push_messages
        copy.notification_push_promotions = self.notification_push_promotions
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: Keys.id.rawValue)
        coder.encode(self.created_at, forKey: Keys.created_at.rawValue)
        coder.encode(self.updated_at, forKey: Keys.updated_at.rawValue)
        coder.encode(self.notification_mail, forKey: Keys.notification_mail.rawValue)
        coder.encode(self.notification_mail_announcements, forKey: Keys.notification_mail_announcements.rawValue)
        coder.encode(self.notification_mail_likes, forKey: Keys.notification_mail_likes.rawValue)
        coder.encode(self.notification_mail_matches, forKey: Keys.notification_mail_matches.rawValue)
        coder.encode(self.notification_mail_messages, forKey: Keys.notification_mail_messages.rawValue)
        coder.encode(self.notification_mail_promotions, forKey: Keys.notification_mail_promotions.rawValue)
        coder.encode(self.notification_push, forKey: Keys.notification_push.rawValue)
        coder.encode(self.notification_push_announcements, forKey: Keys.notification_push_announcements.rawValue)
        coder.encode(self.notification_push_likes, forKey: Keys.notification_push_likes.rawValue)
        coder.encode(self.notification_push_matches, forKey: Keys.notification_push_matches.rawValue)
        coder.encode(self.notification_push_messages, forKey: Keys.notification_push_messages.rawValue)
        coder.encode(self.notification_push_promotions, forKey: Keys.notification_push_promotions.rawValue)
    }

}
func checkForString(_ dict : [String:Any], key : String) -> String
{
    if let st : String = dict[key] as? String
    {
        return st
    }
    else if let int : Int = dict[key] as? Int
    {
        return "\(int)"
    }
    else
    {
        return ""
    }
}

