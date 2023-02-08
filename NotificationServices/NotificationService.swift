//
//  NotificationService.swift
//  NotificationServices
//
//  Created by Anders Teglgaard on 01/06/2020.
//  Copyright © 2020 KrownUnity. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

     override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
           self.contentHandler = contentHandler
           bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

           if let content = bestAttemptContent {
               func failEarly() {
                   contentHandler(request.content)
               }

               guard let apnsData = content.userInfo["data"] as? [String: Any] else {
                   return failEarly()
               }

            guard let mediaURLString = apnsData.first?.value as? String else {
                   return failEarly()
               }

               guard let mediaURL = URL(string: mediaURLString) else {
                   return failEarly()
               }

               URLSession.shared.downloadTask(with: mediaURL, completionHandler: { (location, _, _) in
                   if let downloadedURL = location {
                       let tempDirectory = NSTemporaryDirectory()
                       let tempFile = "file://".appending( tempDirectory).appending( mediaURL.lastPathComponent)
                       let tempURL = URL(string: tempFile)
                       if let tmpUrl = tempURL {
                           try? FileManager.default.moveItem( at: downloadedURL, to: tmpUrl)
                           if let attachment = try? UNNotificationAttachment( identifier: "image.png", url: tmpUrl) {
                               self.bestAttemptContent?.attachments = [attachment]
                           }
                       }
                   }
                   self.contentHandler!(self.bestAttemptContent!)
               }).resume()
           }

        let swipeAction = UNNotificationAction(identifier: "SWIPE_ACTION",
              title: "Swipe",
              options: [.foreground])
        let ignoreAction = UNNotificationAction(identifier: "IGNORE_ACTION",
              title: "Ignore",
              options: [])
        // Define the notification type
        let liveEventCategory = UNNotificationCategory( identifier: "liveEventNotification", actions: [swipeAction, ignoreAction], intentIdentifiers: [], options: [])
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([liveEventCategory])
       }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
