//
//  OneLastActivity.swift
//  XMPP-Messenger-iOS
//
//  Created by Sean Batson on 2015-09-18.
//  Edited by Paul LEMAIRE on 2015-10-09.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public typealias OneMakeLastCallCompletionHandler = (_ response: XMPPIQ?, _ forJID: XMPPJID?, _ error: DDXMLElement?) -> Void

public class OneLastActivity: NSObject {

	var didMakeLastCallCompletionBlock: OneMakeLastCallCompletionHandler?

	// MARK: Singleton

	public class var sharedInstance: OneLastActivity {
		struct OneLastActivitySingleton {
			static let instance = OneLastActivity()
		}
		return OneLastActivitySingleton.instance
	}

	// MARK: Public Functions

	public func getStringFormattedDateFrom(second: UInt) -> NSString {
		if second > 0 {
			let time = NSNumber(value: second)
			let interval = time.doubleValue
			let elapsedTime = NSDate(timeIntervalSince1970: interval)
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "HH:mm:ss"

			return dateFormatter.string(from: elapsedTime as Date) as NSString
		} else {
			return ""
		}
	}

	public func getStringFormattedElapsedTimeFrom(date: NSDate!) -> String {
		var elapsedTime = "nc"
		let startDate = NSDate()
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.day, .weekOfYear, .hour, .minute, .second])
        let components = calendar.dateComponents(unitFlags, from: date as Date, to: startDate as Date)

		if nil == date {
			return elapsedTime
		}

		if 52 < components.weekOfYear! {
			elapsedTime = "more than a year"
		} else if 1 <= components.weekOfYear! {
			if 1 < components.weekOfYear! {
				elapsedTime = "\(components.weekOfYear!) weeks"
			} else {
				elapsedTime = "\(components.weekOfYear!) week"
			}
		} else if 1 <= components.day! {
			if 1 < components.day! {
				elapsedTime = "\(components.day!) days"
			} else {
				elapsedTime = "\(components.day!) day"
			}
		} else if 1 <= components.hour! {
			if 1 < components.hour! {
				elapsedTime = "\(components.hour!) hours"
			} else {
				elapsedTime = "\(components.hour!) hour"
			}
		} else if 1 <= components.minute! {
			if 1 < components.minute! {
				elapsedTime = "\(components.minute!) minutes"
			} else {
				elapsedTime = "\(components.minute!) minute"
			}
		} else if 1 <= components.second! {
			if 1 < components.second! {
				elapsedTime = "\(components.second!) seconds"
			} else {
				elapsedTime = "\(components.second!) second"
			}
		} else {
			elapsedTime = "now"
		}

		return elapsedTime
	}

    // MARK: Simple last activity converter
        public func getLastActivityFrom(timeInSeconds: UInt) -> String {
                let time: NSNumber = NSNumber(value: timeInSeconds)
                var lastSeenInfo = ""

                switch timeInSeconds {
                /*
                    case 0:
                            lastSeenInfo = "online"
                    case _ where timeInSeconds > 0 && timeInSeconds < 60:
                            lastSeenInfo = "last seen \(timeInSeconds) seconds ago"
                    case _ where timeInSeconds > 59 && timeInSeconds < 3600:
                            lastSeenInfo = "last seen \(timeInSeconds / 60) minutes ago"
                    case _ where timeInSeconds > 3600 && timeInSeconds < 86400:
                            lastSeenInfo = "last seen \(timeInSeconds / 3600) hours ago"
                    case _ where timeInSeconds > 86400:
                            let date = NSDate(timeIntervalSinceNow:-time.doubleValue)
                        let dateFormatter = DateFormatter()
                */
                case _ where timeInSeconds >= 0:
                        let date = NSDate(timeIntervalSinceNow: -time.doubleValue)
                    let dateFormatter = DateFormatter()

                        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
                        lastSeenInfo = "\(dateFormatter.string(from: date as Date))"
                    default:
                        lastSeenInfo = "never been online"
                }

            return lastSeenInfo
        }

	public class func sendLastActivityQueryToJID(userName: String, sender: XMPPLastActivity? = nil, completionHandler completion:@escaping OneMakeLastCallCompletionHandler) {
		sharedInstance.didMakeLastCallCompletionBlock = completion
        let userJID = XMPPJID(string: userName)

		sender?.sendQuery(to: userJID)

	}
}

extension OneLastActivity: XMPPLastActivityDelegate {
    /**
     * Callback to obtain the number of idle seconds that the XMPPLastActivity
     * sender should use as answer to a last activity query iq.
     *
     * Each delegate will be asked in turn (the order is not guaranteed) and each of
     * then should decide to return the given idleSeconds value, or a new value as
     * the number of idleSeconds. The first delegate will receive NSNotFound as the
     * value of idleSecond. If the last delegate returns NSNotFound as result, the
     * answer will be 0 seconds.
     */
    public func numberOfIdleTimeSeconds(for sender: XMPPLastActivity!, queryIQ iq: XMPPIQ!, currentIdleTimeSeconds idleSeconds: UInt) -> UInt {
        // I have no clue right now what this function does but i create and return a uint as asked
        let value: UInt = 2
        return value
    }

	public func xmppLastActivity(_ sender: XMPPLastActivity!, didNotReceiveResponse queryID: String!, dueToTimeout timeout: TimeInterval) {
		if let callback = OneLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
			callback(nil, nil, DDXMLElement(name: "TimeOut"))
		}
	}

	public func xmppLastActivity(_ sender: XMPPLastActivity!, didReceiveResponse response: XMPPIQ!) {
        if let callback = OneLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
                    if let resp = response {
                        if resp.forName("error") != nil {
                            if let from = resp.value(forKey: "from") {
                                callback(resp, XMPPJID(string: "\(from)"), resp.forName("error"))
                            } else {
                                callback(resp, nil, resp.forName("error"))
                            }
                        } else {
                            if let from = resp.attribute(forName: "from") {
                                callback(resp, XMPPJID(string: "\(from)"), nil)
                            } else {
                                callback(resp, nil, nil)
                            }
                        }
                    }
                }
        /*
        if OneLastActivity.sharedInstance.didMakeLastCallCompletionBlock != nil {
            if response != nil {
				// FIX BUG: 30 march 2020
                /*if resp.forName("error") != nil {
					if let from = resp.value(forKey: "from") {
                        callback(resp, XMPPJID(string: "\(from)"), resp.forName("error"))
					} else {
						callback(resp, nil, resp.forName("error"))
					}
				} else {
					if let from = resp.attribute(forName: "from") {
                        callback(resp, XMPPJID(string: "\(from)"), nil)
					} else {
						callback(resp, nil, nil)
					}
				}*/
			}
		}
         */
	}

	public func numberOfIdleTimeSecondsForXMPPLastActivity(sender: XMPPLastActivity!, queryIQ iq: XMPPIQ!, currentIdleTimeSeconds idleSeconds: UInt) -> UInt {
		return 30
	}
}
