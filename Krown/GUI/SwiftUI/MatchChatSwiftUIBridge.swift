//
//  MatchChatSwiftUIBridge.swift
//  Krown
//
//  Created by macOS on 10/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI
import Alamofire

struct MatchChatSwiftUIBridge: UIViewControllerRepresentable {

    var matchObject: MatchObject = MatchObject()
    var imgYouUser: String = String()

    func makeUIViewController(context: Context) -> UINavigationController {
        let chatView = MatchesChatViewVC()

        // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
        let jidString = "krownuser_\(matchObject.id)@" + URLHandler.xmpp_domain
        let name = matchObject.name
        OneChats.addUserToChatList(jidStr: jidString, displayName: name)
        let user = OneRoster.userFromRosterForJID(jid: jidString)

        // first read the dictionary from UserDefaults that holds the data
        var unreadMessages = UserDefaults.standard.object(forKey: "unreadMessages") as? [String: Int] ?? [String: Int]()
        // reset the number of unread messages and save
        if unreadMessages[jidString] != nil {
            unreadMessages.updateValue(0, forKey: (jidString))
            UserDefaults.standard.set(unreadMessages, forKey: "unreadMessages")

        }

        chatView.recipientXMPP = user
        chatView.matchObject = matchObject
        chatView.isFromSwiftUI = true
        var headers: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            headers = [.authorization(bearerToken: "ForceRefresh"),]
        }
        AF.request(imgYouUser, method: .get, headers: headers).responseImage { response in
            if case .success(let image) = response.result {
                chatView.imgYouUser = image
            }
        }

        chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: "krownuser_\(matchObject.id)@" + URLHandler.xmpp_domain, senderDisplayName: matchObject.name)
        let chatNavigationController = UINavigationController(rootViewController: chatView)
        chatNavigationController.modalPresentationStyle = .overCurrentContext
        return chatNavigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }

}
