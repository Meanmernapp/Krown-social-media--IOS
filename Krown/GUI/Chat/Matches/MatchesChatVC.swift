//
//  MatchesChatVC.swift
//  Krown
//
//  Created by macOS on 29/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI
import XMPPFramework
import AVFoundation
import CoreData
import Alamofire
import SDWebImage
import MBProgressHUD

class MatchesChatVC: UIViewController {

    @IBOutlet weak var TblView: UITableView!
    @IBOutlet weak var CollView: UICollectionView!
    @IBOutlet weak var vwNoMatches: UIView!
    @IBOutlet weak var vwNewMatches: UIView!
    
    var unfilteredMatches: [MatchObject] = []
    var filteredMatches: [MatchObject] = []
    var waveMatches: [MatchObject] = []
    var arrWaveMatches : [MatchesModel] = []

    var collMatches: [MatchObject] = []

    var mainController: MainController = MainController()
    let searchController = UISearchController(searchResultsController: nil)
    var sortingType = "lastMessage" // will be used for sorting the chat list matches
    var imgYouUser : UIImage?
    var isFilterTap : Bool = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        // Do any additional setup after loading the view.
    }

    func initialSetup() {
        TblView.delegate = self
        TblView.dataSource = self
        TblView.register(UINib(nibName: "ChatTblCell", bundle: nil), forCellReuseIdentifier: "ChatTblCell")
        TblView.register(UINib(nibName: "WaveTblCell", bundle: nil), forCellReuseIdentifier: "WaveTblCell")

        CollView.dataSource = self
        CollView.delegate = self
        CollView.register(UINib(nibName: "ChatImgCollCell", bundle: nil), forCellWithReuseIdentifier: "ChatImgCollCell")

        NotificationCenter.default.addObserver(self, selector: #selector(MatchesChatVC.refreshmatchesList), name: .refreshChatListVC, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MatchesChatVC.updateLastActivity), name: .reorderChatListVC, object: nil)
        if let ownUserID = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as? String
        {
            mainController.getProfile(userID: ownUserID, callback: { (match) in
                if let imageUrl : String = match.imageArray.first {
                    var headers: HTTPHeaders
                    if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                        headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
                    } else {
                        headers = [.authorization(bearerToken: "ForceRefresh"),]
                    }
                    AF.request(imageUrl, method: .get, headers: headers).responseImage { response in
                        if case .success(let image) = response.result {
                            self.imgYouUser = image
                        }
                    }
                }
            })
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        self.refreshmatchesList()
        self.reloadTableview()
        OneMessage.sharedInstance.delegate = self
        OnePresence.sharedInstance.delegate = self
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.layer.zPosition = 0
        tabBarController?.tabBar.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.items?.forEach { $0.isEnabled = true }
        self.tabBarController?.tabBar.frame = UITabBarController().tabBar.frame
        navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.alpha = 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        // used for saving the latest sorting option
//        self.unfilteredMatches = self.filteredMatches
    }

    @objc func refreshmatchesList() {
        let main = mainController
        main.distributeMatchArray(UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String, callback: { (response) in
            if response.count > 1 {
                self.waveMatches.removeAll()
                self.waveMatches = response[1]
            }
            switch self.sortingType {
            case "lastSeen":
                let matchesWithMessageHistory = self.addMessageHistoryTo(matches: response[0])
                let matchesSortedByLastActive = self.sortMatches(matches: matchesWithMessageHistory)
                self.unfilteredMatches = matchesWithMessageHistory
                self.filteredMatches.removeAll()
                self.collMatches.removeAll()
                for match in matchesWithMessageHistory {
                    if (match.messageHistory?.count ?? 0) == 0 {
                        self.collMatches.append(match)
                    }
                }
                for match in matchesSortedByLastActive {
                    if (match.messageHistory?.count ?? 0) > 0 {
                        self.filteredMatches.append(match)
                    }
                }
            case "Unread":
                let matchesWithMessageHistory = self.addMessageHistoryTo(matches: response[0])
                self.unfilteredMatches = matchesWithMessageHistory
                self.filteredMatches.removeAll()
                self.collMatches.removeAll()
                for match in matchesWithMessageHistory {
                    let jidString = "krownuser_\(match.id)@" + URLHandler.xmpp_domain
                    let unreadMessages = UserDefaults.standard.object(forKey: "unreadMessages") as? [String: Int] ?? [String: Int]()
                    if unreadMessages[jidString] != nil {
                        // if number of unread mesages is higher than 0, populat the label to show that number
                        if unreadMessages[jidString]! > 0 {
                            self.filteredMatches.append(match)
                        } else {
                            if (match.messageHistory?.count ?? 0) > 0 {
                                self.filteredMatches.append(match)
                            }
                            self.collMatches.append(match)
                        }
                    } else {
                        if (match.messageHistory?.count ?? 0) > 0 {
                            self.filteredMatches.append(match)
                        }
                        self.collMatches = matchesWithMessageHistory
                    }
                }
            default:
                // Last Message
                // In first load filtered and unfiltered should be set to the unfiltered values.
                let matchesWithMessageHistory = self.addMessageHistoryTo(matches: response[0])
                let matchesSortedByLastMessage = self.sortMatches(matches: matchesWithMessageHistory)
                self.unfilteredMatches = matchesWithMessageHistory
                self.filteredMatches.removeAll()
                self.collMatches.removeAll()
                for match in matchesWithMessageHistory {
                    if (match.messageHistory?.count ?? 0) == 0 {
                        self.collMatches.append(match)
                    }
                }
                for match in matchesSortedByLastMessage {
                    if (match.messageHistory?.count ?? 0) > 0 {
                        self.filteredMatches.append(match)
                    }
                }
            }

            self.reloadTableview()
        })
        
        main.getWaveArray(UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String, callback: { response in
            if response.count > 0{
                self.arrWaveMatches.removeAll()
                self.arrWaveMatches = response
            }
        })
    }

    func addMessageHistoryTo(matches: [MatchObject]) -> [MatchObject] {

        for match in matches {
            let messageHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: "krownuser_\(match.id)@" + URLHandler.xmpp_domain, senderDisplayName: "")

            // check if captured lastActiveTime is newer than one got from PersonController (e.g. when a user has sent a message, we set lastActiveTime to time when the message is sent and PersonController returns the time when the user first logged in to the app
            if ((self.unfilteredMatches.first(where: { $0.id == match.id })) != nil) {

                let lastActiveTime = self.unfilteredMatches.first(where: { $0.id == match.id })!.lastActiveTime

                if lastActiveTime > match.lastActiveTime {
                    match.lastActiveTime = lastActiveTime
                }
            }
            match.messageHistory = messageHistory
        }
        return matches
    }

    func sortMatches(matches: [MatchObject]) -> [MatchObject] {

        switch self.sortingType {
        case "lastSeen":
            return matches.sorted(by: {
                $0.lastActiveTime > $1.lastActiveTime
            })
        case "nearest":
            return matches.sorted(by: {
                Int($0.distance) ?? 0 > Int($1.distance) ?? 0
            })
        default:
            // Last Message
            return matches.sorted(by: {
                var date0 = $0.messageHistory?.first?.sentDate
                var date1 = $1.messageHistory?.first?.sentDate
                if date0 == nil {
                    date0 = Date(timeIntervalSinceReferenceDate: 0)
                }
                if date1 == nil {
                    date1 = Date(timeIntervalSinceReferenceDate: 0)
                }
                return date0!.compare(date1!) == .orderedDescending
            })

        }

    }

    @objc func updateLastActivity(notification: Notification) {
        // used to update the message sender's last activity time
        if let message = notification.object as? XMPPMessage {
            if message.fromStr!.contains("_") && message.fromStr!.contains("@") {
                let fromId = message.fromStr!.slice(from: "_", to: "@")!
                let now = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                self.unfilteredMatches.first(where: { $0.id == fromId })?.lastActiveTime = dateFormatter.string(from: now)

                self.reorderMatches()
            }
        }

    }

    @objc func reorderMatches() {

        let matches = unfilteredMatches
        let matchesSorted = sortMatches(matches: matches)
        unfilteredMatches = matchesSorted
        reloadTableview()
    }

    func reloadTableview() {
        globalConstant.arrMatchesId = collMatches.compactMap({ $0.id})
        vwNoMatches.isHidden = collMatches.count + filteredMatches.count + waveMatches.count == 0 ? false : true
        vwNewMatches.isHidden = collMatches.count == 0 ? true : false
        if self.TblView != nil {
            self.TblView.reloadData()
            if isFilterTap == false {
                self.CollView.reloadData()
            }
            isFilterTap = false
        }
    }

    func actionSheetResponse(_ sender: String) {
        if self.sortingType != sender {
            switch sender {
            case "lastMessage":
                self.sortingType = "lastMessage"
                self.isFilterTap = true
                self.refreshmatchesList()
            case "nearest":
                self.sortingType = "nearest"
                self.isFilterTap = true
                self.refreshmatchesList()
            default:
                // Last Message
                self.sortingType = "Unread"
                self.isFilterTap = true
                self.refreshmatchesList()
            }
        }
    }
    @IBAction func btnDiscoverPeopleClicked(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBSegueAction func showActionSheet(_ coder: NSCoder) -> UIViewController? {
        let detailsView = HalfModalViewUIKit()
        return UIHostingController(coder: coder, rootView: detailsView)
    }
   

    
    @IBAction func btnFilter(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)

            guard let customAlertVC = storyboard.instantiateViewController(
                    identifier: "CustomAlertVC") as? CustomAlertVC else {
                fatalError("Cannot load from storyboard")
            }
        customAlertVC.modalPresentationStyle = .custom
        customAlertVC.transitioningDelegate = customAlertVC
        customAlertVC.matchesChatVC = self
        customAlertVC.strImgArr = [["value":"By latest message","action":"lastMessage"],
                                   ["value":"By nearest","action":"nearest"],
                                   ["value":"Unread","action":"Unread"]]
        self.present(customAlertVC, animated: true, completion: nil)
    }
    
    // Todo: Mpve this to a more appropriate place
    func lastMessageText(message: MessageObject) -> (String) {
        var textLbl = String()

        switch message.kind {
        case .text(let text):
            textLbl = text
        case .attributedText(let text):
            textLbl = text.string
        case  .emoji(let text):
            textLbl = text
        case .photo, .video:
            textLbl = "Photo Message"
        case .location:
            textLbl = "Location Message"
        case .audio(_):
            textLbl = ""
        case .contact(_):
            textLbl = ""
        case .custom(_):
            textLbl = ""
        case .linkPreview(_):
            textLbl = ""
        }
        return textLbl
    }
    // WIP: Consider moving this to a controller
    func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        //Add authentication header
        var header : String
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            header = UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String
        } else {
            header = "ForceRefresh"
        }
        let headers: [AnyHashable : Any] = [
            "content-type": "application/json",
            "authorization": "Bearer \(header)"
        ]
        let asset: AVURLAsset = AVURLAsset.init(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])

        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            //print("Error: \(error)")
            return nil
        }

        return UIImage(cgImage: thumbnailImageRef)
    }
    func getLastMessage(cell: ChatTblCell) {
        let messageHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: "krownuser_\(cell.matchObject.id)@" + URLHandler.xmpp_domain, senderDisplayName: "")
        cell.matchObject.messageHistory = messageHistory // For updating the messagehistory. Workaround
        if messageHistory.count > 0 {
            let lastMessage = messageHistory[0]
            // Time Label

//            let lastActity = OneLastActivity()
//            let timeString = lastActity.getStringFormattedElapsedTimeFrom(date: lastMessage.sentDate as NSDate)
//            cell.dateLbl.text = timeString

            if lastMessage.sender.senderId == "krownuser_\(cell.matchObject.id)@" + URLHandler.xmpp_domain {
                // Last message was the receipient
                cell.lbl_msg.text = lastMessageText(message: lastMessage)
            } else {
                // Last message was you
                cell.lbl_msg.text = "You: \(lastMessageText(message: lastMessage))"
            }
        } else {
            // No messages ever sent
            cell.lbl_msg.text = ""
        }
    }

    func setupBadge(cell: ChatTblCell, unreadMessages: [String: Int]) {
        let jidString = "krownuser_\(cell.matchObject.id)@" + URLHandler.xmpp_domain

        let fontSize: CGFloat = 14
        cell.badge.font = UIFont.systemFont(ofSize: fontSize)
        cell.badge.textAlignment = .center
        cell.badge.textColor = .white
        cell.badge.backgroundColor = .red
        // Add count to label and size to fit
        cell.badge.text = String(unreadMessages[jidString]!)
        cell.badge.sizeToFit()

        // Adjust frame to be square for single digits or elliptical for numbers > 9
        var frame: CGRect = cell.badge.frame
        frame.size.height += CGFloat(Int(0.4 * fontSize))
        frame.size.width = (unreadMessages[jidString]! <= 9) ? frame.size.height : frame.size.width + CGFloat(Int(fontSize))
        cell.badge.frame = frame

        // Set radius and clip to bounds
        cell.badge.layer.cornerRadius = frame.size.height / 2.0
        cell.badge.clipsToBounds = true
    }

}

extension MatchesChatVC: OneMessageDelegate,OnePresenceDelegate {
    // MARK: Chat message Delegates

    public func oneStream(sender: XMPPStream, composingUser user: XMPPUserCoreDataStorageObject, userIsComposing: Bool) {

    }
    public func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject, ofType type: String) {
        // When a message is received while the chat is open we will not update the tableview
        self.reloadTableview()

    }
    // MARK: OnePresenceDelegate
    func onePresenceDidReceivePresence(_ sender: XMPPStream, didReceive presence: XMPPPresence) {

        let now = Date()
        if let from = presence.attributeStringValue(forName: "from") {

            if let fromId = from.slice(from: "_", to: "@") {

                if let to = presence.attributeStringValue(forName: "to") {

                    if let toId = to.slice(from: "_", to: "@") {

                        if fromId != toId {

                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                            self.unfilteredMatches.first(where: { $0.id == fromId })?.lastActiveTime = dateFormatter.string(from: now)
                            self.reorderMatches()
                        }

                    }

                }

            }

        }

    }
}

extension MatchesChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      tableView.isHidden = filteredMatches.count + waveMatches.count == 0 ? true : false
        return filteredMatches.count + ((waveMatches.count > 0) ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && (waveMatches.count > 0){
            let cell: WaveTblCell = tableView.dequeueReusableCell(withIdentifier: "WaveTblCell", for: indexPath) as! WaveTblCell
            cell.setData(waveMatches)
            return cell
        }
        let cell: ChatTblCell = tableView.dequeueReusableCell(withIdentifier: "ChatTblCell", for: indexPath) as! ChatTblCell

        let match: MatchObject

        match = filteredMatches[indexPath.row - ((waveMatches.count > 0) ? 1 : 0)]
        // BUG: This shows up several times in log
        var path = ""
            if let resourcePath = Bundle.main.resourcePath {
              let imgName = "man"
              path = resourcePath + "/" + imgName
            }
        var imageUrl = URL(fileURLWithPath: path)

              if match.imageArray.count > 0 {
                imageUrl = URL(string: match.imageArray[0])!
              }

        /*
        do {
            var imageUrl = try URL(string: " ")!
            
        } catch  {
            //print("imageUrl is nil")
        }
        */

        // For handling GIF like video and other picture types
        if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
            
            // DiscoverPeopleVideoPlayer supports cache
            let queuePlayer = DiscoverPeopleVideoPlayer.shared.play(with: imageUrl)
            let playerLayer = AVPlayerLayer(player: queuePlayer)
            
            playerLayer.frame = view.layer.bounds
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.player = queuePlayer

            cell.imgUser.layer.addSublayer(playerLayer)
            queuePlayer.play()
            
        } else {
            let lastPartComponent = WebKeyhandler.imageHandling.thumbnailProfileImage + imageUrl.lastPathComponent
            imageUrl.deleteLastPathComponent()
            imageUrl.appendPathComponent(lastPartComponent)
            
            cell.loadImage(imageUrl)
        }

        cell.imgUser.contentMode = UIView.ContentMode.scaleAspectFill
        cell.lbl_user_name.text = match.name
        cell.matchObject = match
        // Makes the cell transparent
        cell.backgroundColor = UIColor.clear
        cell.img_online.isHidden = true
        let jidString = "krownuser_\(match.id)@" + URLHandler.xmpp_domain
        // first read the dictionary from UserDefaults that holds the data for unread messages
        let unreadMessages = UserDefaults.standard.object(forKey: "unreadMessages") as? [String: Int] ?? [String: Int]()

        if unreadMessages[jidString] != nil {
            // if number of unread mesages is higher than 0, populat the label to show that number
            if unreadMessages[jidString]! > 0 {
                // edit the appearance of the label
//                setupBadge(cell: cell, unreadMessages: unreadMessages)
                cell.img_online.isHidden = false
            }
        }
        // Last Message
        getLastMessage(cell: cell)

        return cell


    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 101
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((waveMatches.count > 0) && indexPath.row != 0) || waveMatches.count == 0{
            let chatView = MatchesChatViewVC()
            let cell = tableView.cellForRow(at: indexPath) as! ChatTblCell

            let match: MatchObject

            match = filteredMatches[indexPath.row - ((waveMatches.count > 0) ? 1 : 0)]

            // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
            let jidString = "krownuser_\(cell.matchObject.id)@" + URLHandler.xmpp_domain
            let name = match.name
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
            chatView.matchObject = cell.matchObject
            chatView.imgYouUser = imgYouUser
            chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: "krownuser_\(cell.matchObject.id)@" + URLHandler.xmpp_domain, senderDisplayName: match.name)

            if user != nil {
                // Check to make sure that the user is there
               // let chatNavigationController = UINavigationController(rootViewController: chatView)
                // Transition
                
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                self.navigationController?.pushViewController(chatView, animated: true)
               
            } else {
                // Present messages that there is a network error to the server
                //print("Network error")
            }
        } else if ((waveMatches.count > 0) && indexPath.row == 0) {
//            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
//
//                guard let waveListVC = storyboard.instantiateViewController(
//                        identifier: "WaveListVC") as? WaveListVC else {
//                    fatalError("Cannot load from storyboard")
//                }
//
////            var arrMatches : [MatchObjectModel] = [MatchObjectModel]()
////            for match in waveMatches {
////                var dict : [String:Any] = [String:Any]()
////                dict["id"] = match.id
////                dict["name"] = match.name
////                dict["imageArray"] = match.imageArray
////                dict["lastActiveTime"] = match.lastActiveTime
////                dict["distance"] = match.distance
////                arrMatches.append(MatchObjectModel.init(dict))
////            }
//            waveListVC.matchesModel = waveMatches
//          //  waveListVC.tabBarController?.tabBar.isHidden = true
//            print(waveMatches.count)
//            waveListVC.imgYouUser = self.imgYouUser
//            self.navigationController?.pushViewController(waveListVC, animated: true)

            
            self.tabBarController?.tabBar.isHidden = false
            let swiftUIView = ListPeopleViews(matchesModel: arrWaveMatches, isEventFor: "", viewType: viewtype.waveView)
            let hostingController = UIHostingController(rootView: swiftUIView)
            let waveView = UINavigationController.init(rootViewController: hostingController)
            //UIView.performWithoutAnimation {
                self.showDetailViewController(waveView, sender: self)
           // }



        }
    }
}
extension MatchesChatVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collMatches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ChatImgCollCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatImgCollCell", for: indexPath) as? ChatImgCollCell
        let match: MatchObject

        match = collMatches[indexPath.item]
        // BUG: This shows up several times in log
        var path = ""
            if let resourcePath = Bundle.main.resourcePath {
              let imgName = "man"
              path = resourcePath + "/" + imgName
            }
        var imageUrl = URL(fileURLWithPath: path)

              if match.imageArray.count > 0 {
                imageUrl = URL(string: match.imageArray[0])!
              }

        //print("Index : \(indexPath.item) URL : \(imageUrl.absoluteString)")
        
        if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
            
            // DiscoverPeopleVideoPlayer supports cache
            let queuePlayer = DiscoverPeopleVideoPlayer.shared.play(with: imageUrl)
            let playerLayer = AVPlayerLayer(player: queuePlayer)
            
            playerLayer.frame = view.layer.bounds
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.player = queuePlayer

            cell?.imgUser.layer.addSublayer(playerLayer)
            queuePlayer.play()
            
        } else {
            let lastPartComponent = WebKeyhandler.imageHandling.thumbnailProfileImage + imageUrl.lastPathComponent
            imageUrl.deleteLastPathComponent()
            imageUrl.appendPathComponent(lastPartComponent)
            
            cell?.loadImage(imageUrl)
        }
        
        cell?.imgUser.contentMode = UIView.ContentMode.scaleAspectFill
        cell?.matchObject = match
        // Makes the cell transparent
//krownuser_36505250@chat.krownunity.com
        // Last Message

        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 70, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chatView = MatchesChatViewVC()
        let cell = collectionView.cellForItem(at: indexPath) as! ChatImgCollCell

        let match: MatchObject

        match = collMatches[indexPath.item]

        // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
        let jidString = "krownuser_\(cell.matchObject.id)@" + URLHandler.xmpp_domain
        let name = match.name
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
        chatView.matchObject = cell.matchObject
        chatView.imgYouUser = imgYouUser
        chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: "krownuser_\(cell.matchObject.id)@" + URLHandler.xmpp_domain, senderDisplayName: match.name)

        if user != nil {
            // Check to make sure that the user is there
          //  let chatNavigationController = UINavigationController(rootViewController: chatView)

//            // Transition
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(chatView, animated: true)
        } else {
            Log.log(message: "Network error or else the user does not exist on server %@", type: .debug, category: Category.chat, content: "")
        }
    }
}
#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct MatchesChatVCPreview: PreviewProvider {
    
    static var previews: some View {
        // view controller using programmatic UI
        UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(identifier: "MatchesChatVC").toPreview()
    }
}
#endif

