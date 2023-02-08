//
//  MatchesModel.swift
//  Krown
//
//  Created by Mac Mini 2020 on 08/06/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//


import UIKit
import SwiftUI
import AVKit

class MatchesModel: NSObject, Codable, NSCopying, NSCoding, Identifiable  {
    
    enum Keys: String {
        case id
        case last_active
        case email
        case first_name
        case last_name
        case current_latitude
        case current_longitude
        case profile_pic_url
        case sex
        case pushtoken
        case dob
        case status
        case employer
        case position
        case school
        case concentration
        case distance
        case interests
        case matched
    }
    
    var id: String?
    var created_at: String?
    var updated_at: String?
    var last_active: String?
    var email: String?
    var first_name: String?
    var last_name: String?
    var current_latitude: String?
    var current_longitude: String?
    var profile_pic_url: [ProfilePictureModel]?
    var sex: String?
    var dob: String?
    var status: String?
    var employer: String?
    var position: String?
    var school: String?
    var concentration: String?
    var distance: String?
    var interests: [InterestModel]?
    var matched : String?
    
    init(_ dict:[String:Any]) {
        id = checkForString(dict, key : Keys.id.rawValue)
        last_active = checkForString(dict, key : Keys.last_active.rawValue)
        email = checkForString(dict, key : Keys.email.rawValue)
        first_name = checkForString(dict, key : Keys.first_name.rawValue)
        last_name = checkForString(dict, key : Keys.last_name.rawValue)
        current_latitude = checkForString(dict, key : Keys.current_latitude.rawValue)
        current_longitude = checkForString(dict, key : Keys.current_longitude.rawValue)
        if let profilePictureArray = dict[Keys.profile_pic_url.rawValue] as? [[String:Any]] {
            self.profile_pic_url = profilePictureArray.map({ ProfilePictureModel($0) })
        }
        sex = checkForString(dict, key : Keys.sex.rawValue)
        dob = checkForString(dict, key : Keys.dob.rawValue)
        status = checkForString(dict, key : Keys.status.rawValue)
        employer = checkForString(dict, key : Keys.employer.rawValue)
        position = checkForString(dict, key : Keys.position.rawValue)
        school = checkForString(dict, key : Keys.school.rawValue)
        concentration = checkForString(dict, key : Keys.concentration.rawValue)
        distance = checkForString(dict, key : Keys.distance.rawValue)
        if let interestArray = dict[Keys.interests.rawValue] as? [[String:Any]] {
            self.interests = interestArray.map({ InterestModel($0) })
        }
        matched = checkForString(dict, key : Keys.matched.rawValue)
    }
    required init?(coder: NSCoder) {
        self.distance = coder.decodeObject(forKey: Keys.distance.rawValue) as? String
        self.id = coder.decodeObject(forKey: Keys.id.rawValue) as? String
        self.last_active = coder.decodeObject(forKey: Keys.last_active.rawValue) as? String
        self.email = coder.decodeObject(forKey: Keys.email.rawValue) as? String
        self.first_name = coder.decodeObject(forKey: Keys.first_name.rawValue) as? String
        self.last_name = coder.decodeObject(forKey: Keys.last_name.rawValue) as? String
        self.current_latitude = coder.decodeObject(forKey: Keys.current_latitude.rawValue) as? String
        self.current_longitude = coder.decodeObject(forKey: Keys.current_longitude.rawValue) as? String
        self.profile_pic_url = coder.decodeObject(forKey: Keys.profile_pic_url.rawValue) as? [ProfilePictureModel]
        self.sex = coder.decodeObject(forKey: Keys.sex.rawValue) as? String
        self.dob = coder.decodeObject(forKey: Keys.dob.rawValue) as? String
        self.status = coder.decodeObject(forKey: Keys.status.rawValue) as? String
        self.employer = coder.decodeObject(forKey: Keys.employer.rawValue) as? String
        self.position = coder.decodeObject(forKey: Keys.position.rawValue) as? String
        self.school = coder.decodeObject(forKey: Keys.school.rawValue) as? String
        self.concentration = coder.decodeObject(forKey: Keys.concentration.rawValue) as? String
        self.interests = coder.decodeObject(forKey: Keys.interests.rawValue) as? [InterestModel]
        self.matched = coder.decodeObject(forKey: Keys.matched.rawValue) as? String
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MatchesModel([:])
        copy.id = self.id
        copy.distance = self.distance
        copy.created_at = self.created_at
        copy.updated_at = self.updated_at
        copy.last_active = self.last_active
        copy.email = self.email
        copy.first_name = self.first_name
        copy.last_name = self.last_name
        copy.current_latitude = self.current_latitude
        copy.current_longitude = self.current_longitude
        copy.profile_pic_url = self.profile_pic_url
        copy.sex = self.sex
        copy.dob = self.dob
        copy.status = self.status
        copy.employer = self.employer
        copy.position = self.position
        copy.school = self.school
        copy.concentration = self.concentration
        copy.interests = self.interests
        copy.matched = self.matched
        return copy
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: Keys.id.rawValue)
        coder.encode(self.distance, forKey: Keys.distance.rawValue)
        coder.encode(self.last_active, forKey: Keys.last_active.rawValue)
        coder.encode(self.email, forKey: Keys.email.rawValue)
        coder.encode(self.first_name, forKey: Keys.first_name.rawValue)
        coder.encode(self.last_name, forKey: Keys.last_name.rawValue)
        coder.encode(self.current_latitude, forKey: Keys.current_latitude.rawValue)
        coder.encode(self.current_longitude, forKey: Keys.current_longitude.rawValue)
        coder.encode(self.profile_pic_url, forKey: Keys.profile_pic_url.rawValue)
        coder.encode(self.sex, forKey: Keys.sex.rawValue)
        coder.encode(self.dob, forKey: Keys.dob.rawValue)
        coder.encode(self.status, forKey: Keys.status.rawValue)
        coder.encode(self.employer, forKey: Keys.employer.rawValue)
        coder.encode(self.position, forKey: Keys.position.rawValue)
        coder.encode(self.school, forKey: Keys.school.rawValue)
        coder.encode(self.concentration, forKey: Keys.concentration.rawValue)
        coder.encode(self.interests, forKey: Keys.interests.rawValue)
        coder.encode(self.matched, forKey: Keys.matched.rawValue)
    }
    
}
func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage)->Void)) {
    DispatchQueue.global().async { //1
        let asset = AVAsset(url: url) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbImage = UIImage(cgImage: cgThumbImage) //7
            DispatchQueue.main.async { //8
                completion(thumbImage) //9
            }
        } catch {
            //print(error.localizedDescription) //10
            DispatchQueue.main.async {
                completion(UIImage(named: "placeholder")!) //11
            }
        }
    }
}


