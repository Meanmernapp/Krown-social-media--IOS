//
//  OneMessage.swift
//  OneChat
//
//  Created by Paul on 27/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework
import Alamofire
import MessageKit
import CoreData

public typealias OneChatMessageCompletionHandler = (_ stream: XMPPStream, _ message: XMPPMessage) -> Void

// MARK: Protocols

public protocol OneMessageDelegate {
    func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject, ofType type: String)
    func oneStream(sender: XMPPStream, composingUser: XMPPUserCoreDataStorageObject, userIsComposing: Bool)

}

public class OneMessage: NSObject {
    public var delegate: OneMessageDelegate?

    public var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchiving: XMPPMessageArchiving?
    var didSendMessageCompletionBlock: OneChatMessageCompletionHandler?
    var isFriendFromOpenChat: XMPPJID?
    var saveObserverToken: Any? // setting CoreData Notifications

    // MARK: Singleton

    public class var sharedInstance: OneMessage {
        struct OneMessageSingleton {
            static let instance = OneMessage()
        }

        return OneMessageSingleton.instance
    }

    // MARK: private methods

    func setupArchiving() {
        xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)

        xmppMessageArchiving?.clientSideMessageArchivingOnly = false
        xmppMessageArchiving?.activate(OneChat.sharedInstance.xmppStream!)
        xmppMessageArchiving?.addDelegate(self, delegateQueue: DispatchQueue.main)
    }

    // MARK: public methods
    // Sending messages requires to be called from main queue
    public class func sendMessage(message: String, to receiver: String, is type: String, completionHandler completion:@escaping OneChatMessageCompletionHandler) {

        let body = DDXMLElement.element(withName: "body") as! DDXMLElement
        let messageID = OneChat.sharedInstance.xmppStream?.generateUUID

        body.stringValue = message

        let completeMessage = DDXMLElement.element(withName: "message") as! DDXMLElement

        completeMessage.addAttribute(withName: "id", stringValue: messageID!)
        let customFields = DDXMLElement.element(withName: "customFields") as! DDXMLElement
        customFields.addAttribute(withName: "type", stringValue: type)
        completeMessage.addChild(customFields)

        completeMessage.addAttribute(withName: "to", stringValue: receiver)
        completeMessage.addAttribute(withName: "type", stringValue: WebKeyhandler.Chat.xmppChat) // INFO: This always have to be chat or else the server cant figure out what it is receiving.

        completeMessage.addChild(body)

        sharedInstance.didSendMessageCompletionBlock = completion
        OneChat.sharedInstance.xmppStream?.send(completeMessage)

        // Send push message
        let receiverUserID = receiver.slice(from: "_", to: "@")
        sendPushMessage(message: message, senderUserID: receiver, receiverUserID: receiverUserID!) { (_) in

        }
    }

    public func deleteMessage(jid: String, messageID: String) {
            // From: https://xmpp.org/extensions/xep-0424.html
            //        <message type='chat' to='lord@capulet.example' id='retract-message-1'>
            //          <apply-to id="origin-id-1" xmlns="urn:xmpp:fasten:0">
            //            <retract xmlns='urn:xmpp:message-retract:0'/>
            //          </apply-to>
            //          <fallback xmlns="urn:xmpp:fallback:0"/>
            //          <body>This person attempted to retract a previous message, but it's unsupported by your client.</body>
            //          <store xmlns="urn:xmpp:hints"/>
            //        </message>

            let message = DDXMLElement.element(withName: "message") as! DDXMLElement

            message.addAttribute(withName: "type", stringValue: "chat")
            // message.addAttribute(withName: "to", stringValue: "krownuser_61193304@chat.krownunity.com")
            message.addAttribute(withName: "to", stringValue: jid)
            message.addAttribute(withName: "id", stringValue: "retract-message-1")

            let applyTo = DDXMLElement.element(withName: "apply-to") as! DDXMLElement
            // applyTo.addAttribute(withName: "id", stringValue: "14174222-60A1-43A6-908F-0F7942952049")
            applyTo.addAttribute(withName: "id", stringValue: messageID)
            applyTo.addAttribute(withName: "xmlns", stringValue: "urn:xmpp:fasten:0")

            let retract = DDXMLElement(name: "retract", xmlns: "urn:xmpp:message-retract:0")

            applyTo.addChild(retract)
            message.addChild(applyTo)

            OneChat.sharedInstance.xmppStream?.send(message)

        }

    public func sendDiscoveryRequest() {

        let iq = DDXMLElement.element(withName: "iq") as! DDXMLElement
        iq.addAttribute(withName: "type", stringValue: "get")
        iq.addAttribute(withName: "from", stringValue: "krownuser_10154260958043998" + URLHandler.xmpp_domain)
        iq.addAttribute(withName: "to", stringValue: "krownuser_10154260958043998@" + URLHandler.xmpp_domain)
        iq.addAttribute(withName: "id", stringValue: "info1")
        let query = DDXMLElement.element(withName: "query") as! DDXMLElement
        query.addAttribute(withName: "xmlns", stringValue: "http://jabber.org/protocol/disco#info")
        iq.addChild(query)
        OneChat.sharedInstance.xmppStream?.send(iq)

            }

    public class func sendPushMessage( message: String, senderUserID: String, receiverUserID: String, callback: @escaping (NSDictionary) -> Void) {

        let mainController = MainController()
        mainController.sendPushMessage(message: message, receiverUserID: receiverUserID) { (response) in
        callback(response)
        }

    }

    public class func sendIsComposingMessage(recipient: String, completionHandler completion:@escaping OneChatMessageCompletionHandler) {
        if recipient.count > 0 {
            let message = DDXMLElement.element(withName: "message") as! DDXMLElement
            message.addAttribute(withName: "type", stringValue: WebKeyhandler.Chat.xmppChat)
            message.addAttribute(withName: "to", stringValue: recipient)

            let composing = DDXMLElement.element(withName: "composing", stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLElement
            message.addChild(composing)

            sharedInstance.didSendMessageCompletionBlock = completion
            OneChat.sharedInstance.xmppStream?.send(message)
        }
    }

    public class func sendIsNotComposingMessage(recipient: String, completionHandler completion:@escaping OneChatMessageCompletionHandler) {
        if recipient.count > 0 {
            let message = DDXMLElement.element(withName: "message") as! DDXMLElement
            message.addAttribute(withName: "type", stringValue: WebKeyhandler.Chat.xmppChat)
            message.addAttribute(withName: "to", stringValue: recipient)

            let active = DDXMLElement.element(withName: "paused", stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLElement
            message.addChild(active)

            sharedInstance.didSendMessageCompletionBlock = completion
            OneChat.sharedInstance.xmppStream?.send(message)
        }
    }

    public func loadArchivedMessagesFrom(jid: String, senderDisplayName: String) -> ([MessageObject]) {
        // Memory issue in this function when used with this id: 10154260958043998 potentially also with others
        // Be careful about pointing to object in this class because it will take up a crazy amount of memory
        let moc = xmppMessageStorage?.mainThreadManagedObjectContext
        moc?.undoManager = nil
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<XMPPMessageArchiving_Message_CoreDataObject>()
        let predicateFormat = "bareJidStr like %@ "
        let predicate = NSPredicate(format: predicateFormat, jid)

        let sortDecriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        let sortDecriptors = [sortDecriptor]
        var retrievedMessages = [MessageObject]()

        request.sortDescriptors = sortDecriptors
        request.predicate = predicate
        request.entity = entityDescription

        let coreDataRepository = CoreDataRepository<XMPPMessageArchiving_Message_CoreDataObject>(managedObjectContext: moc!)
        let answer = coreDataRepository.get(predicate: predicate, entityDescription: entityDescription!, sortDescriptors: sortDecriptors)
        switch answer {
        case .success(let results):
            for message in results {
                var element: DDXMLElement!
                do {

                    element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                } catch _ {
                    element = nil
                }

                let body: String
                let date: Date
                let sendingEntity: String
                let type: String
                let messageString: String
                let messageID: String

                date = message.timestamp as Date

                if message.body != nil {
                    body = message.body
                } else {
                    body = ""
                }

                messageID = element!.attributeStringValue(forName: "id")!

                if element.attributeStringValue(forName: "to") == jid {
                    let displayName = OneChat.sharedInstance.xmppStream?.myJID
                    sendingEntity = displayName!.bare
                } else {
                    sendingEntity = jid
                }
                // Does the message contain a type" XML
                if let typeInMessage = element?.elements(forName: "customFields")[0].attributeStringValue(forName: "type") {
                    type = typeInMessage
                } else {
                    type = ""
                }

                if message.messageStr != nil {
                    messageString = message.messageStr
                } else {
                    messageString = ""
                }

                let messageObject = OneMessage.generateMessage(messageText: body, messageID: messageID, messageString: messageString, senderId: sendingEntity, senderDisplayName: "", date: date, type: type)

                retrievedMessages.append(messageObject)
                moc?.refresh(message, mergeChanges: false)
            }
        case .failure(let error):
            fatalError("Failed to loadArchivedMessagesFrom method. \(error.localizedDescription)")
        }
        return retrievedMessages // THe function looked like this: return retrievedMessages.mutableCopy() as! (NSMutableArray)
    }

    public class func generateMessage(messageText: String, messageID: String, messageString: String, senderId: String, senderDisplayName: String, date: Date, type: String) -> (MessageObject) {
        let sender = ChatUserObject(senderId: senderId, displayName: senderDisplayName)

        switch type {
        case WebKeyhandler.Chat.xmppChat:
            let messageObject = MessageObject(text: messageText, sender: sender, messageId: messageID, date: date)
         return messageObject

        case WebKeyhandler.Chat.xmppLocation:

         let coordinateArray = messageText.components(separatedBy: " ")

         let latitude  = Double(coordinateArray[0])
         let longitude = Double(coordinateArray[1])
         let locationCoordinates = CLLocation.init(latitude: CLLocationDegrees.init(latitude!), longitude: CLLocationDegrees.init(longitude!))
            let messageObject = MessageObject(location: locationCoordinates, sender: sender, messageId: messageID, date: date)
         return messageObject

        case WebKeyhandler.Chat.xmppPhoto:
        let image = UIImage(named: "cameraImage")!
        let mediaItem = MessageMediaItem(image: image, url: URL(string: messageText)!)
            let messageObject = MessageObject(kind: .photo(mediaItem), sender: sender, messageId: messageID, date: date)
                return messageObject

         default:
            break
         }
        return MessageObject()
    }

    public func synchronizeMessagesFor() {
        let iq = DDXMLElement.element(withName: "iq") as! DDXMLElement
        iq.addAttribute(withName: "id", stringValue: "krownuser_10154260958043998")
        iq.addAttribute(withName: "type", stringValue: "get")

        let list = DDXMLElement.element(withName: "list") as! DDXMLElement
        list.addAttribute(withName: "xmls", stringValue: "urn:xmpp:archive")
        list.addAttribute(withName: "with", stringValue: "krownuser_10154260958043998@" + URLHandler.xmpp_domain)

        let set = DDXMLElement.element(withName: "set") as! DDXMLElement
        set.addAttribute(withName: "xmls", stringValue: "http://jabber.org/protocol/rsm")
        set.addAttribute(withName: "MAX", doubleValue: 100)

        list.addChild(set)
        iq.addChild(list)

        OneChat.sharedInstance.xmppStream?.send(iq)

    }
    public func deleteMessagesBasedOnIDFrom(jid: String, messageID: String) {
            let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
            let request = NSFetchRequest<NSFetchRequestResult>()
            let predicateFormat = "messageStr CONTAINS %@ "
            let predicate = NSPredicate(format: predicateFormat, messageID)

            request.predicate = predicate
            request.entity = entityDescription

        let coreDataRepository = CoreDataRepository<XMPPMessageArchiving_Message_CoreDataObject>(managedObjectContext: moc!)
        let answer = coreDataRepository.get(predicate: predicate, entityDescription: entityDescription!)

        switch answer {
        case .success(let results):
            for message in results {
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(xmlString: (message).messageStr)
                } catch _ {
                    element = nil
                }

                if element.attributeStringValue(forName: "messageStr") == String(describing: message) {
                    coreDataRepository.delete(entity: message)
                }
            }

            coreDataRepository.save()
        case .failure(let error):
            fatalError("Failed to perform deletion deleteMessagesBasedOnID \(error.localizedDescription)")
        }

}

    public func deleteMessagesFrom(jid: String, messages: NSArray) {
        messages.enumerateObjects({ (message, _, _) -> Void in
            let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
            let request = NSFetchRequest<NSFetchRequestResult>()
            let predicateFormat = "messageStr like %@ "
            let predicate = NSPredicate(format: predicateFormat, message as! String)

            request.predicate = predicate
            request.entity = entityDescription

            let coreDataRepository = CoreDataRepository<XMPPMessageArchiving_Message_CoreDataObject>(managedObjectContext: moc!)
            let answer = coreDataRepository.get(predicate: predicate, entityDescription: entityDescription!)

            switch answer {
            case .success(let results):
                for message in results {
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: (message).messageStr)
                    } catch _ {
                        element = nil
                    }

                    if element.attributeStringValue(forName: "messageStr") == String(describing: message) {
                        coreDataRepository.delete(entity: message)
                    }
                }
                coreDataRepository.save()
            case .failure(let error):
                fatalError("Failed to perform deleteMessagesFrom \(error.localizedDescription)")
            }
        })
    }

}

extension OneMessage: XMPPStreamDelegate {

    public func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        if let completion = OneMessage.sharedInstance.didSendMessageCompletionBlock {
            completion(sender, message)
        }
        // TODO: Research if this is needed. This line below creates an error. Might be crucial to make it all work but is outcommented in original  from processone
        // OneMessage.sharedInstance.didSendMessageCompletionBlock!(sender, message)

    }
    public func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        let user = OneChat.sharedInstance.xmppRosterStorage.user(for: message.from, xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: OneRoster.sharedInstance.managedObjectContext_roster())

        let senderJidString = (sender.myJID?.user)! + "@" + URLHandler.xmpp_domain// made for making the jidstring without a found user to add them

        // INFO: For setting up the toast
        // If sending messages through other services to Krown i.e. been hacked then this can protect some of the weird messages being received.
        if message.fromStr!.contains("_") && message.fromStr!.contains("@") {

        let receiverUserID = message.fromStr!.slice(from: "_", to: "@")!

        // TODO: fix crude solution
        if message.elements(forName: "customFields").count != 0 {
            if (message.elements(forName: "customFields")[0].attributeStringValue(forName: "type")!).isEmpty == false {
            // This here adds the other user if the user was not already added
            OneChats.addUserToChatList(jidStr: (senderJidString), displayName: "")

                let customMessageType = message.elements(forName: "customFields")[0].attributeStringValue(forName: "type")!

            // Post toast in system if the user is not present in an open chat window.
            if OneMessage.sharedInstance.isFriendFromOpenChat != nil { // chat is open
                if user!.jid! != OneMessage.sharedInstance.isFriendFromOpenChat! { // Check if it is the user displayed writing if not then
                    AlertController().displayToast(for: receiverUserID, with: messageText(message: message.body!, type: customMessageType))
                }
            } else {
                // Chat is closed set toast
                AlertController().displayToast(for: receiverUserID, with: messageText(message: message.body!, type: customMessageType))

            }

                OneMessage.sharedInstance.delegate?.oneStream(sender: sender, didReceiveMessage: message, from: user!, ofType: customMessageType)

                // handle the number of unread messages, this will serve in ChatListVC to show a badge with number of unread messages
                // first create a dictionary in UserDefaults that will hold the data
                var unreadMessages = UserDefaults.standard.object(forKey: "unreadMessages") as? [String: Int] ?? [String: Int]()
                // set initial value of the unreadMessages for a given jid, the value will be 1 since there is already one new message received and save
                if unreadMessages[String(describing: message.from!.bareJID)] == nil {
                    unreadMessages.updateValue(1, forKey: String(describing: message.from!.bareJID))
                    UserDefaults.standard.set(unreadMessages, forKey: "unreadMessages")
                } else {
                    // if the value for unreadMessages alread exist increase it by one and save
                    var number = unreadMessages[String(describing: message.from!.bareJID)]
                    number! += 1
                    unreadMessages.updateValue(number!, forKey: String(describing: message.from!.bareJID))
                    UserDefaults.standard.set(unreadMessages, forKey: "unreadMessages")

                }

                // Update the chat
                NotificationCenter.default.post(name: .reorderChatListVC, object: message)

        }
        }
        }

        // check if retract exists
        if let retractedMessage = message.attribute(forName: "id")?.stringValue {
              if retractedMessage == "retract-message-1" {
                // notify ChatViewVC about delete intention
                NotificationCenter.default.post(name: .refreshChatViewVCafterDeletion, object: message)
              }
            }

        // Bug FIX: 20 MARCH 2020
        /*if let _ = message.forName("composing") {
                OneMessage.sharedInstance.delegate?.oneStream(sender: sender, composingUser: user!, userIsComposing: true )
            } else if let _ = message.forName("paused") {
                OneMessage.sharedInstance.delegate?.oneStream(sender: sender, composingUser: user!, userIsComposing: false)

        }*/

        }

    // This has been borrowed from ChatListVC (lastMessageText)
    func messageText(message: String, type: String) -> (String) {
        var textLbl = String()

        switch type {
        case WebKeyhandler.Chat.xmppChat:
            textLbl = message
        case WebKeyhandler.Chat.xmppPhoto:
            textLbl = "Photo Message"
        case WebKeyhandler.Chat.xmppLocation:
            textLbl = "Location Message"
        default:
            textLbl = ""
        }
        return textLbl
    }
}

/*
extension OneMessage {
    
    func addSaveNotificationObserver(){
        removeSaveNotificationObserver()
        saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext, queue: nil, using: handleSaveNotification(notification:))
    }
    
    func removeSaveNotificationObserver(){
        if let token = saveObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func handleSaveNotification(notification:Notification){
        print(OneChat.sharedInstance.xmppRosterStorage.managedObjectContext.automaticallyMergesChangesFromParent)
    }
}
*/
