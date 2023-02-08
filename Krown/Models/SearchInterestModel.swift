//
//  SearchInterestModel.swift
//  Krown
//
//  Created by Mac Mini 2020 on 08/06/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation

class SearchInterestModel : Identifiable{
    
    var interest: String
    var id: String
    var created_at: String
    var updated_at: String
   
    init (interest: String, id: String, created_at : String, updated_at : String) {
        
        self.interest = interest
        self.id = id
        self.created_at = created_at
        self.updated_at = updated_at
        
    }
    convenience init() {
        self.init(interest: "", id: "", created_at : "",updated_at: "")
    }
}
