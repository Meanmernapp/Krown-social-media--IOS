//
//  OnePresence.swift
//  OneChat
//
//  Created by Paul on 27/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

// MARK: Protocol
public protocol OnePresenceDelegate {
    func onePresenceDidReceivePresence(_ sender: XMPPStream, didReceive presence: XMPPPresence)

}

public class OnePresence: NSObject {
    var delegate: OnePresenceDelegate?

	// MARK: Singleton

	class var sharedInstance: OnePresence {
		struct OnePresenceSingleton {
			static let instance = OnePresence()
		}
		return OnePresenceSingleton.instance
	}

	// MARK: Functions

	class func goOnline() {
		let presence = XMPPPresence()
		OneChat.sharedInstance.xmppStream?.send(presence)
        //print("xmppStream Connected and authenticated")
	}

	class func goOffline() {
		var _ = XMPPPresence(type: "unavailable")
	}
}

extension OnePresence: XMPPStreamDelegate {

    public func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {

        OnePresence.sharedInstance.delegate?.onePresenceDidReceivePresence(sender, didReceive: presence)

    }

}
