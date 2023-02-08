//
//  OneRoster.swift
//  OneChat
//
//  Created by Paul on 26/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public protocol OneRosterDelegate {

	func oneRosterContentChanged(controller: NSFetchedResultsController<NSFetchRequestResult>)
}

public class OneRoster: NSObject, NSFetchedResultsControllerDelegate {
	public var delegate: OneRosterDelegate?
	public var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?

	// MARK: Singleton

	public class var sharedInstance: OneRoster {
		struct OneRosterSingleton {
			static let instance = OneRoster()
		}
		return OneRosterSingleton.instance
	}

	public class var buddyList: NSFetchedResultsController<NSFetchRequestResult> {
		get {
			if sharedInstance.fetchedResultsControllerVar != nil {
				return sharedInstance.fetchedResultsControllerVar!
			}
			return sharedInstance.fetchedResultsController()!
		}
	}

	// MARK: Core Data

	func managedObjectContext_roster() -> NSManagedObjectContext {
        return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
	}

	private func managedObjectContext_capabilities() -> NSManagedObjectContext {
		return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
	}

	public func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
		if fetchedResultsControllerVar == nil {
			let moc = OneRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
			let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
			let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
			let sd2 = NSSortDescriptor(key: "displayName", ascending: true)

			let sortDescriptors = [sd1, sd2]
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>()

			fetchRequest.entity = entity
			fetchRequest.sortDescriptors = sortDescriptors
			fetchRequest.fetchBatchSize = 10

			fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
			fetchedResultsControllerVar?.delegate = self

			do {
				try fetchedResultsControllerVar!.performFetch()
			} catch let error as NSError {
				print("Error: \(error.localizedDescription)")
				abort()
			}
			//  if fetchedResultsControllerVar?.performFetch() == nil {
			// Handle fetch error
			// }
		}

		return fetchedResultsControllerVar!
	}

	public class func userFromRosterAtIndexPath(indexPath: NSIndexPath) -> XMPPUserCoreDataStorageObject {
		return sharedInstance.fetchedResultsController()!.object(at: indexPath as IndexPath) as! XMPPUserCoreDataStorageObject
	}

	public class func userFromRosterForJID(jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID(string: jid)

		if let user = OneChat.sharedInstance.xmppRosterStorage.user(for: userJID, xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: sharedInstance.managedObjectContext_roster()) {
            Log.log(message: "User found in coredata %@", type: .debug, category: Category.coreData, content: "")
			return user
		} else {
            Log.log(message: "User NOT found in coredata %@", type: .debug, category: Category.coreData, content: "")
			return nil
		}
	}
    public class func addUserToRoster(jidStr: String, displayName: String) {

        let userToBeAdded: String = jidStr
        let jid: XMPPJID = XMPPJID(string: userToBeAdded)!
        let OCShared = OneChat.sharedInstance
        OCShared.xmppRoster?.addUser(jid, withNickname: displayName)

    }
	public class func removeUserFromRosterAtIndexPath(indexPath: NSIndexPath) {
		let user = userFromRosterAtIndexPath(indexPath: indexPath)
		sharedInstance.fetchedResultsControllerVar?.managedObjectContext.delete(user)
	}

	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.oneRosterContentChanged(controller: controller)
	}
}

extension OneRoster: XMPPRosterDelegate {

    public func xmppStream(_ sender: XMPPStream!, didReceiveError error: DDXMLElement!) {

    }

    public func xmppRoster(_ sender: XMPPRoster, didReceivePresenceSubscriptionRequest presence: XMPPPresence) {
        // Add user to roster from presence subscription
        let jid: XMPPJID = XMPPJID(string: String(describing: "\(presence.from!.user!)\(URLHandler.xmpp_domainResource)"))!
        sender.subscribePresence(toUser: jid )

        sender.acceptPresenceSubscriptionRequest(from: presence.from!, andAddToRoster: true)
        // add user to roster from presence.from()
    }

	public func xmppRoster(sender: XMPPRoster, didReceiveBuddyRequest presence: XMPPPresence) {
		// was let user
        _ = OneChat.sharedInstance.xmppRosterStorage.user(for: presence.from, xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: managedObjectContext_roster())
	}

    public func xmppRosterDidEndPopulating(_ sender: XMPPRoster) {

        // This can be used to check who is in Roster
        // let jidList = OneChat.sharedInstance.xmppRosterStorage.jids(for: OneChat.sharedInstance.xmppStream!)
        // print("Roster List=\(String(describing: jidList))")
        //print("Roster List was downloaded")

	}
}
