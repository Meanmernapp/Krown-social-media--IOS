//  Log.swift
//  Krown
//
//  Created by KrownUnity on 09/05/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import os

private let subsystem = Bundle.main.bundleIdentifier!

struct Category {
    static let location = "Location"
    static let chat = "Chat"
    static let networking = "Networking"
    static let discover = "Discover People"
    static let coreData = "Core Data"
    static let thirdParty = "Third Party"
    static let notifications = "Notifications"
    static let login = "Login"
    static let lifeCycle = "Life Cycle Management"
}

final class Log {
    // String interpolated messages are only supported in iOS 14 and above.
    // Usage:- Log.createLog(fileName: filename).logType(interpolated message)
    // To add Privacy refer follwing example in message -> "User \(username, privacy: .private) logged in"
    
    // Allowed categories in logging for debugging purposes.
    static let XMPPLoggingIsOn : Bool = false
    static let LoggedCategories : [String] =
    [
     Category.location,
     //Category.chat,
     Category.networking,
     Category.discover,
     Category.coreData,
     Category.thirdParty,
     Category.notifications,
     Category.login,
     Category.lifeCycle
    ]
    
    @available(iOS 14, *)
    static func log(fileName: String) -> Logger {
        Logger.createLog(fileName: fileName)
    }

    // This is a must to declare even in signpost or normal logging is to be done.
    static func createLog(category: String) -> OSLog {
       let logHandler = OSLog(subsystem: subsystem, category: category)
       return logHandler
    }

    // To perform logging when particular event is performed, pass .pointsOfInterest
    static func createLog(category: OSLog.Category) -> OSLog {
        let logHandler = OSLog(subsystem: subsystem, category: category)
       return logHandler
    }

    // Usage:- message should be passed in C style environment
    // Default:- %@ to display value
    // To add privacy:- use {public}, {private}, eg: %{public}@ to show or hide info in logger
    static func log(message: StaticString, type: OSLogType, category: String, content: CVarArg) {
        if(LoggedCategories.contains(category)){
            let log = OSLog(subsystem: subsystem, category: category)
            os_log(message, log: log, type: type, String(describing: "\(content)"))
        }
    }

    // Usage:- use .begin in type parameter before the code which has to be debugged and .end after that code.
    // To monitor the results. Open Xcode Instruments tool. Product -> Profile -> Choosing a blank template -> Clicking on + icon on right side. Search desired os_signPost and select it -> Click O icon to start recording and sqaure to end it and in below results will appear.
    // Referred from :- https://www.raywenderlich.com/605079-migrating-to-unified-logging-console-and-instruments#toc-anchor-009
    // Also some references :- Measuring performance through logging (WWDC 2018)
    // perferred for synchronous operations
    static func osSignPost(type: OSSignpostType, log: OSLog, processName: StaticString, content: String) {
        os_signpost(type, log: log, name: processName, "%@", content)
    }

    // step2 for async logging declaration. Step 1 is declaring the log
    static func osSignPostID(log: OSLog) -> OSSignpostID {
        let signPostID = OSSignpostID(log: log)
        return signPostID
    }

    // or if the signpostid only to referred with a particular class. (Optional)
    static func osSignPostID(log: OSLog, withObject: AnyObject) -> OSSignpostID {
        let signPostID = OSSignpostID(log: log, object: withObject)
        return signPostID
    }

    // preferred for async operations
    // step3 for async logging declaration
    static func osSignPost(withSignPostID: OSSignpostID, type: OSSignpostType, log: OSLog, processName: StaticString, content: String) {
        os_signpost(type, log: log, name: processName, "%@", content)
    }

}

@available(iOS 14, *)
extension Logger {
    static func createLog(fileName: String) -> Logger {
        return Logger(subsystem: subsystem, category: fileName)
    }
}
