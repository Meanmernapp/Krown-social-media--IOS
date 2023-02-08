//
//  InterestModel.swift
//  Krown
//
//  Created by Mac Mini 2020 on 08/06/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation

class InterestModel: NSObject, Codable, NSCopying, NSCoding, Identifiable  {
    
    static func == (lhs: InterestModel, rhs: InterestModel) -> Bool {
        return lhs.common == rhs.common && lhs.interest == rhs.interest && lhs.interest_id == rhs.interest_id && lhs.member_id == rhs.member_id && lhs.isSelected == rhs.isSelected
    }
    
    enum Keys: String {
        case common
        case interest
        case interest_id
        case member_id
        case isSelected
    }
    
    var common: String?
    var interest: String?
    var interest_id: String?
    var member_id: String?
    var isSelected: Bool?
    
    init(_ dict:[String:Any]) {
        common = checkForString(dict, key : Keys.common.rawValue)
        interest = checkForString(dict, key : Keys.interest.rawValue)
        interest_id = checkForString(dict, key : Keys.interest_id.rawValue)
        member_id = checkForString(dict, key : Keys.member_id.rawValue)
        isSelected = dict[Keys.isSelected.rawValue] as? Bool
      
    }
    init (common: String, interest: String, interest_id: String, member_id: String, isSelected: Bool) {

        self.common = common
        self.interest = interest
        self.interest_id = interest_id
        self.member_id = member_id
        self.isSelected = isSelected
    }
    required init?(coder: NSCoder) {
        self.common = coder.decodeObject(forKey: Keys.common.rawValue) as? String
        self.interest = coder.decodeObject(forKey: Keys.interest.rawValue) as? String
        self.interest_id = coder.decodeObject(forKey: Keys.interest_id.rawValue) as? String
        self.member_id = coder.decodeObject(forKey: Keys.member_id.rawValue) as? String
        self.isSelected = coder.decodeBool(forKey: Keys.isSelected.rawValue)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = InterestModel([:])
        copy.common = self.common
        copy.interest = self.interest
        copy.interest_id = self.interest_id
        copy.member_id = self.member_id
        copy.isSelected = self.isSelected
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.common, forKey: Keys.common.rawValue)
        coder.encode(self.interest, forKey: Keys.interest.rawValue)
        coder.encode(self.interest_id, forKey: Keys.interest_id.rawValue)
        coder.encode(self.member_id, forKey: Keys.member_id.rawValue)
        coder.encode(self.isSelected, forKey: Keys.isSelected.rawValue)
    }
    
}



