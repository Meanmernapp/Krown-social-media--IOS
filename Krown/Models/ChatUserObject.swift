//
//  ChatUserObject.swift
//  Krown
//
//  Created by Anders Teglgaard on 09/04/2020.
//  Copyright © 2020 KrownUnity. All rights reserved.
//

import Foundation
import MessageKit

class ChatUserObject: SenderType {
    var senderId: String
    var displayName: String

    init (senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
    convenience init() {
        self.init(senderId: "", displayName: "")
    }
}
