//
//  MailHelper.swift
//  Krown
//
//  Created by macOS on 31/12/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import Foundation
import MessageUI

class MailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = MailHelper()
    private override init() {
        //
    }
    
    func sendEmail(subject:String, body:String, to:String){
        if !MFMailComposeViewController.canSendMail() {
            // Utilities.showErrorBanner(title: "No mail account found", subtitle: "Please setup a mail account")
            return //EXIT
        }
        
        let picker = MFMailComposeViewController()
        
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
        MailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        MailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        UIApplication.shared.windows[0].rootViewController!

         // OR If you use SwiftUI 2.0 based WindowGroup try this one
         // UIApplication.shared.windows.first?.rootViewController
    }
}
