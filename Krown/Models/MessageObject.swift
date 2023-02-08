//
//  MessageObject.swift
//  Krown
//
//  Created by Anders Teglgaard on 27/01/2017.
//  Copyright © 2017 KrownUnity. All rights reserved.
//

import UIKit
import Foundation
import MessageKit
import CoreLocation

public struct MessageMediaItem: MediaItem {

    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize

    init(image: UIImage, url: URL) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
        self.url = url
    }

}
private struct MessageLocationItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }

}

public struct MessageObject: MessageType {
    public var kind: MessageKind
    public var messageId: String
    public var sender: SenderType
    public var sentDate: Date

    init(kind: MessageKind, sender: SenderType, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }

    init(image: UIImage, sender: SenderType, messageId: String, date: Date) {
        let url = URL(string: URLHandler.imageUploadDomain) // Bug: When this url is set to nonexistent sites it throws NSErrorFailingURLStringKey
        let placeholderMessage = MessageMediaItem(image: image, url: url!)
        self.init(kind: .photo(placeholderMessage), sender: sender, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, sender: SenderType, messageId: String, date: Date) {
        let url = URL(string: URLHandler.imageUploadDomain) // Bug: When this url is set to nonexistent sites it throws NSErrorFailingURLStringKey
        let placeholderMessage = MessageMediaItem(image: thumbnail, url: url!)
        self.init(kind: .video(placeholderMessage), sender: sender, messageId: messageId, date: date)
    }

    init(location: CLLocation, sender: SenderType, messageId: String, date: Date) {
        let placeholderMessage = MessageLocationItem(location: location)
        self.init(kind: .location(placeholderMessage), sender: sender, messageId: messageId, date: date)
    }

    init(emoji: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
    }

    init () {
        let sender = ChatUserObject(senderId: "", displayName: "")
        self.init(kind: .emoji(""), sender: sender, messageId: "", date: Date())
    }

}
