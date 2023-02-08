//
//  OneChats.swift
//  OneChat
//
//  Created by Paul on 04/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public class OneChats: NSObject, NSFetchedResultsControllerDelegate {

    var chatList = NSMutableArray()
    var chatListBare = NSMutableArray()

    // MARK: Class function
    class var sharedInstance: OneChats {
        struct OneChatsSingleton {
            static let instance = OneChats()
        }
        return OneChatsSingleton.instance
    }

    public class func getChatsList() -> NSArray {
        if 0 == sharedInstance.chatList.count {
            if let chatList: NSMutableArray = sharedInstance.getActiveUsersFromCoreDataStorage() as? NSMutableArray {

                    chatList.enumerateObjects({ (jidStr, _, _) -> Void in
                    // OneChats.sharedInstance.getUserFromXMPPCoreDataObject(jidStr: jidStr as! String)

                    if let user = OneRoster.userFromRosterForJID(jid: jidStr as! String) {
                        OneChats.sharedInstance.chatList.add(user)
                    }
                })
            }
        }
        return sharedInstance.chatList
    }

    private func getActiveUsersFromCoreDataStorage() -> NSArray? {
        let moc = OneMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let predicateFormat = "streamBareJidStr like %@ "

        let coreDataRepository = CoreDataRepository<XMPPMessageArchiving_Message_CoreDataObject>(managedObjectContext: moc!)

        if let predicateString = UserDefaults.standard.string(forKey: "kXMPPmyJID") {
            let predicate = NSPredicate(format: predicateFormat, predicateString)
           let answer = coreDataRepository.get(predicate: predicate, entityDescription: entityDescription!)
            switch answer {
            case .success(let results):
                let archivedMessage = NSMutableArray()

                for message in results {
                    var element: DDXMLElement!

                    do {
                        element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)// I dont know the type /Anders
                    } catch _ {
                        element = nil
                    }

                    let sender: String

                    if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: "kXMPPmyJID")! && !(element.attributeStringValue(forName: "to")! as NSString).contains(UserDefaults.standard.string(forKey: "kXMPPmyJID")!) {
                        sender = element.attributeStringValue(forName: "to")!
                        if !archivedMessage.contains(sender) {
                            archivedMessage.add(sender)
                        }
                    }
                }
                return archivedMessage
            case .failure(let error):
                fatalError("Failed to getActiveUsers from coreData storage: \(error.localizedDescription)")
            }
        }
        return nil
    }

    private func getUserFromXMPPCoreDataObject(jidStr: String) -> NSMutableArray? {
        let moc = OneRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
        var predicate: NSPredicate

        if OneChat.sharedInstance.xmppStream == nil {
            predicate = NSPredicate(format: "jidStr == %@", jidStr)
        } else {
            predicate = NSPredicate(format: "jidStr == %@ AND streamBareJidStr == %@", jidStr, UserDefaults.standard.string(forKey: "kXMPPmyJID")!)
        }

        let coreDataRepository = CoreDataRepository<XMPPUserCoreDataStorageObject>(managedObjectContext: moc!)
        let answer = coreDataRepository.get(predicate: predicate, entityDescription: entityDescription!, fetchLimit: 1)
        switch  answer {
        case .success(let results):
            let archivedMessage = NSMutableArray()
            for user in results {
                //print(user)
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(xmlString: (user as AnyObject).messageStr)
                } catch _ {
                    element = nil
                }

                let sender: String

                if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: "kXMPPmyJID")! && !(element.attributeStringValue(forName: "to")! as NSString).contains(UserDefaults.standard.string(forKey: "kXMPPmyJID")!) {
                    sender = element.attributeStringValue(forName: "to")!
                          if !archivedMessage.contains(sender) {
                            archivedMessage.add(sender)
                          }
                        }
            }
            //print("so response \(archivedMessage.count) from \(archivedMessage)")
            return archivedMessage
        case .failure(let error):
            fatalError("Failed to getUser from XMPPcoreData object: \(error.localizedDescription)")
        }
    }

    public class func knownUserForJid(jidStr: String) -> Bool {
        if (OneRoster.userFromRosterForJID(jid: jidStr) ?? nil) != nil {
            return true
        } else {
            return false
        }
    }

    public class func addUserToChatList(jidStr: String, displayName: String) {
        if !knownUserForJid(jidStr: jidStr) {
            Log.log(message: "User added to roster %@", type: .debug, category: Category.chat, content: "")
            OneRoster.addUserToRoster(jidStr: jidStr, displayName: displayName)
        }else{
            Log.log(message: "User not added to roster %@", type: .debug, category: Category.chat, content: "")
        }
    }

    public class func removeUserAtIndexPath(indexPath: NSIndexPath) {
        let user = OneChats.getChatsList().object(at: indexPath.row) as! XMPPUserCoreDataStorageObject

        sharedInstance.removeMyUserActivityFromCoreDataStorageWith(user: user)
        sharedInstance.removeUserActivityFromCoreDataStorage(user: user)
        removeUserFromChatList(user: user)
    }

    public class func removeUserFromChatList(user: XMPPUserCoreDataStorageObject) {
        if sharedInstance.chatList.contains(user) {
            sharedInstance.chatList.removeObject(identicalTo: user)
            sharedInstance.chatListBare.removeObject(identicalTo: user.jidStr!)
        }
    }

    func removeUserActivityFromCoreDataStorage(user: XMPPUserCoreDataStorageObject) {
        let moc = OneMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let predicateFormat = "bareJidStr like %@ "

        let predicate = NSPredicate(format: predicateFormat, user.jidStr)
        let coreDataRepository = CoreDataRepository<XMPPMessageArchiving_Message_CoreDataObject>(managedObjectContext: moc!)
        let answers = coreDataRepository.get(predicate: predicate, entityDescription: entityDescription!)

        switch answers {
        case .success(let results):
            for message in results {
                coreDataRepository.delete(entity: message)
            }
        case .failure(let error):
            fatalError("failed to removeUserActivity \(error.localizedDescription)")
        }
    }

    func removeMyUserActivityFromCoreDataStorageWith(user: XMPPUserCoreDataStorageObject) {
        let moc = OneMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let predicateFormat = "streamBareJidStr like %@ "

        if let predicateString = UserDefaults.standard.string(forKey: "kXMPPmyJID") {
            let predicate = NSPredicate(format: predicateFormat, predicateString)
            let coreDataRepository = CoreDataRepository<XMPPMessageArchiving_Message_CoreDataObject>(managedObjectContext: moc!)
            let answer = coreDataRepository.get(predicate: predicate, entityDescription: entityDescription!)

            switch answer {
            case .success(let results):
                for message in results {
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                    } catch _ {
                        element = nil
                    }

                    if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: "kXMPPmyJID")! && !(element.attributeStringValue(forName: "to")! as NSString).contains(UserDefaults.standard.string(forKey: "kXMPPmyJID")!) {
                        if element.attributeStringValue(forName: "to") == user.jidStr {
                            coreDataRepository.delete(entity: message)
                        }
                    }
                }
            case .failure(let error):
                fatalError("Failed to perform removeMyUserActivityFromCoreDataStorageWithuser \(error.localizedDescription)")
            }
        }
    }
}
