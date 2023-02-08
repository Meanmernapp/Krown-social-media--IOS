//
//  ProfilePictureModel.swift
//  Krown
//
//  Created by Anders Teglgaard on 26/07/2022.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation

class ProfilePictureModel: NSObject, Codable, NSCopying, NSCoding, Identifiable  {
    
    enum ProfilePictureKeys: String {
        case image_url
        case index
        case created_at
    }
    
    var image_url: String?
    var index: String?
    var created_at: String?
    
    
    init(_ dict:[String:Any]) {
        image_url = checkForString(dict, key : ProfilePictureKeys.image_url.rawValue)
        index = checkForString(dict, key : ProfilePictureKeys.index.rawValue)
        created_at = checkForString(dict, key : ProfilePictureKeys.created_at.rawValue)
        
    }
    required init?(coder: NSCoder) {
        self.image_url = coder.decodeObject(forKey: ProfilePictureKeys.image_url.rawValue) as? String
        self.index = coder.decodeObject(forKey: ProfilePictureKeys.index.rawValue) as? String
        self.created_at = coder.decodeObject(forKey: ProfilePictureKeys.created_at.rawValue) as? String
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ProfilePictureModel([:])
        copy.index = self.index
        copy.index = self.index
        copy.created_at = self.created_at
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.image_url, forKey: ProfilePictureKeys.image_url.rawValue)
        coder.encode(self.index, forKey: ProfilePictureKeys.index.rawValue)
        coder.encode(self.created_at, forKey: ProfilePictureKeys.created_at.rawValue)
    }
    
}



