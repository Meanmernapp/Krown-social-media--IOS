//
//  MatchVC.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import XMPPFramework
import FirebaseCrashlytics
import Alamofire
import SwiftUI
import IQKeyboardManagerSwift

class MatchVC: UIViewController, OneMessageDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func oneStream(sender: XMPPStream, composingUser: XMPPUserCoreDataStorageObject, userIsComposing: Bool) {

    }

    public func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject, ofType type: String) {
    }

    var match = MatchObject(id: "", name: "", imageArray: [String](), lastActiveTime: "", distance: "0", interests: [InterestModel]() )

//    @IBOutlet weak var congratsLbl: UILabel!
    @IBOutlet weak var userPic: UIImageView!
//    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var matchPic: UIImageView!
    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblMatchValue: UILabel!
    @IBOutlet weak var userPicView: UIView!
    @IBOutlet weak var matchPicView: UIView!
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var btnSendMessage: UIButton!

    //@IBOutlet weak var imgvwMessageSendBG: UIImageView!
    @IBOutlet weak var vwAttachButtons: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var vwBlackOverlay: UIView!
    @IBOutlet weak var vwBlackOverLayView: UIView!

    @IBOutlet weak var vwChatInput: UIView!
    
    @IBOutlet weak var pageCollView: UICollectionView!
    @IBOutlet weak var topSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingSpacingChatInputConstraint: NSLayoutConstraint!
    @IBOutlet weak var traillingSpacingChatInputConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthOfPages: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthOfPaperClip: NSLayoutConstraint!

    @IBOutlet weak var btnPaperClip: UIButton!

    
//    @IBOutlet weak var topLayout: NSLayoutConstraint! //86 , 36
    
    @IBOutlet weak var txtSendChatMessage: MultilineTextField!
    @IBOutlet weak var constraintHeightChatInput: NSLayoutConstraint!

    var cTime : Float = Float()
    var y : CGFloat = CGFloat()

    var selectedIdx : Int = Int()
    var isFromGoing : Bool = false
    var arrayMatchTitles:[String] = ["Meet me","Zodiac Compatability","Both of you love","You crossed paths"]
    var isKeyboardHide = true
    var isPresented : Bool = false
    
    var looperOwnImage: Looper? {
        didSet {
            configLooperOwnImage()
        }
    }
    var looperMatchImage: Looper? {
        didSet {
            configLooperMatchImage()
        }
    }
    var chatUser : XMPPUserCoreDataStorageObject?
    var jidString = ""

    //MARK: - Life Cycle methods
    override func viewDidLoad() {

        addUserToXamppUser()
        registerKeyboardEvents()
        registerCollectionViewCell()
        setUpUI()
        self.configureInputBarAccessoryView()
        
        setUpData()
        viewTopBar.isHidden = isFromGoing ? false : true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tabBarController?.tabBar.isHidden = false
//        self.hidesBottomBarWhenPushed = true
//        self.tabBarController?.tabBar.isHidden = true
//        self.tabBarController?.tabBar.layer.zPosition = -1
//        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        self.txtSendChatMessage.text = ""
        // Due to a bug between iqkeyboardmanager and the messagekit iqmanager is switched off for the chat
        IQKeyboardManager.shared.enable = false
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
        // Due to a bug between iqkeyboardmanager and the messagekit iqmanager is switched off for the chat
//        IQKeyboardManager.shared.enable = false
        
        removeKeyboardEvents()
    }
    override func viewDidDisappear(_ animated: Bool) {
        // INFO: This user might have attended events you do not attended and suggested events therefore needs a refresh
        NotificationCenter.default.post(name: .refreshMenuVC, object: nil)
        // Refresh the chat list to include new match
        NotificationCenter.default.post(name: .refreshChatListVC, object: nil)

    }
    //MARK: - Add user to xampp user
    func addUserToXamppUser()
    {
        jidString = URLHandler.userPreFix + "\(match.id)@" + URLHandler.xmpp_domain
        OneChats.addUserToChatList(jidStr: jidString, displayName: match.name)
        Thread.sleep(forTimeInterval: 0.1)
        chatUser = OneRoster.userFromRosterForJID(jid: URLHandler.userPreFix + match.id + URLHandler.xmpp_domainResource)

    }
    //MARK: - SetUp UI
    func setUpUI()
    {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))

        vwBlackOverLayView.addGestureRecognizer(tapGestureRecognizer)
        // Answers.logCustomEvent(withName: "Match", customAttributes: [:])
//        viewTopBar.isHidden = !isFromGoing
        
        topSpacingConstraint.constant = UIScreen.main.bounds.height * 0.1834 - 20
//        constraintWidthOfPages.constant = CGFloat(10 * (arrayMatchTitles.count - 1))
        txtSendChatMessage.backgroundColor = UIColor.clear
        txtSendChatMessage.placeholder =  "Introduce yourself..."

        
        btnPaperClip.setTitle("", for: .normal)
        
        txtSendChatMessage.delegate = self
        vwChatInput.layer.cornerRadius = vwChatInput.frame.size.height/2
        vwChatInput.layer.masksToBounds = true
        
//        topLayout.constant = isFromGoing ? 86 : 36
//        OneMessage.sendMessage(message: "", to: URLHandler.userPreFix + "\(match.id)@" + URLHandler.xmpp_domain, is: WebKeyhandler.Chat.xmppMatch) { (_, _) in
//        }
        
        userPicView.makeRoundView()
        matchPicView.makeRoundView()
        setChatInputsOnHideKeyboard()
        
        [btnCamera,btnGallery,btnLocation,btnSendMessage].forEach { button in
            button?.setTitle("", for: .normal)
            
        }
    }
    //MARK: - Configure accessory input bar
    func configureInputBarAccessoryView() {
        
        let window = UIApplication.shared.windows.first
        let bottomPadding : CGFloat = window?.safeAreaInsets.bottom ?? 0
        let height : CGFloat = 63 + bottomPadding
        let width : CGFloat = window?.frame.width ?? 0
        y = (window?.frame.height ?? 0) - height
        
        /*bottomView = BottomChat(frame: CGRect(x: 0, y: y, width: width, height: height))
        bottomView.txtChat.delegate = self
//      bottomView.txtChat.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//      bottomView.txtChat.addTarget(self, action: #selector(self.myTargetFunction(_:)), for: .touchDown)
        
        bottomView.btn_attachment.addTarget(self, action: #selector(self.btn_attachment(_:)), for: .touchUpInside)
        bottomView.btn_camera.addTarget(self, action: #selector(self.btn_camera(_:)), for: .touchUpInside)
        bottomView.btn_gallery.addTarget(self, action: #selector(self.btn_gallery(_:)), for: .touchUpInside)
        bottomView.btn_location.addTarget(self, action: #selector(self.btn_location(_:)), for: .touchUpInside)
        bottomView.btn_send.addTarget(self, action: #selector(self.btn_send(_:)), for: .touchUpInside)
        
        resetStackButton()
        if isFromSwiftUI {
            bottomView.removeFromSuperview()
            hostingController?.view.addSubview(bottomView)
            //            self.presentationController?.presentedView?.addSubview(bottomView)
//            self.rootView.view.addSubview(bottomView)
//            bottomView.bringSubviewToFront(UIApplication.shared.windows[0].rootViewController!.view)
        } else {
            self.view.addSubview(bottomView)
        }
        messageInputBar.isHidden = true*/

    }
    //MARK: - Tap gesture view
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        //print("did tap view", sender)
        self.view.endEditing(true)
        setChatInputsOnHideKeyboard()
    }
    //MARK: - SetUp Data
    func setUpData()
    {
        // Setup of the user who was matched with
        let matchUrl = URL(string: (match.imageArray[0] as String))!
        // Set profile images
        // For handling GIF like video and other picture types
        if matchUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {

            looperMatchImage = PlayerLooper(videoURL: matchUrl, loopCount: -1)

        } else {

            let placeholderImage = UIImage(named: "man.jpg")!
            //Add authentication header
            var imageUrlRequest = URLRequest(url: matchUrl)
            var headers: HTTPHeaders
            if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
            } else {
                headers = [.authorization(bearerToken: "ForceRefresh"),]
            }
            imageUrlRequest.headers = headers
            matchPic.af.setImage(
                withURLRequest: imageUrlRequest,
                placeholderImage: placeholderImage,
                imageTransition: .crossDissolve(0.2), completion: { (_) in
            })

        }


        // Setup of yourself
        // BUG: When user has no images, this crashes.
        
        if let ownData = (UserDefaults.standard.object(forKey: WebKeyhandler.User.facebookProfilePics) as? NSArray){
            if (ownData.count > 0) == true{
                let selfUrl = URL(string: ownData[0] as? String ?? "") ?? URL(fileURLWithPath: "")
                if selfUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                    looperOwnImage = PlayerLooper(videoURL: selfUrl, loopCount: -1)
                } else {

                    let placeholderImage = UIImage(named: "man.jpg")!
                    //Add authentication header
                    var imageUrlRequest = URLRequest(url: selfUrl)
                    var headers: HTTPHeaders
                    if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                        headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
                    } else {
                        headers = [.authorization(bearerToken: "ForceRefresh"),]
                    }
                    imageUrlRequest.headers = headers
                    userPic.af.setImage(
                        withURLRequest: imageUrlRequest,
                        placeholderImage: placeholderImage,
                        imageTransition: .crossDissolve(0.2), completion: { (_) in
                    })
                }
            }
            else{
                let placeholderImage = UIImage(named: "man.jpg")!
                userPic.image = placeholderImage
            }
        }
        else{
            let placeholderImage = UIImage(named: "man.jpg")!
            userPic.image = placeholderImage
        }
      
    
        let firstname: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.firstName) as! String
//        lblMatchName.text = firstname

        lblMatchValue.text =  match.name

    }
//    //MARK:- Register Keyboard events
//    func registerKeyboardEvents()
//    {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object:nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification , object:nil)
//    }
    //MARK: - Register Keyboard methods
    func registerKeyboardEvents()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            //print("Keyboard show height - ",keyboardSize.height)
            
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                setChatInputsOnShowKeyboard()
            }
        }

    }

    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            //print("Keyboard hide height - ",keyboardSize.height)

            if self.view.frame.origin.y != 0 {
//                self.view.frame.origin.y += keyboardSize.height
                self.view.frame.origin.y = 0
                setChatInputsOnHideKeyboard()
            }
        }
    }
    //MARK: - Remove keyboard notify events
    func removeKeyboardEvents()
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)


    }
    //MARK: - Register cells
    func registerCollectionViewCell()
    {
        pageCollView.dataSource = self
        pageCollView.delegate = self
        pageCollView.register(UINib(nibName: "PageControllCollCell", bundle: nil), forCellWithReuseIdentifier: "PageControllCollCell")
    }
    //MARK: - Other methods
    func makeNextScreenVisible()
    {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false)
    }
    func configLooperMatchImage() {
        looperMatchImage?.start(in: matchPic.layer)

    }
    func configLooperOwnImage() {
        looperOwnImage?.start(in: userPic.layer)

    }
    func setChatInputsOnHideKeyboard()
    {
        isKeyboardHide = true
        vwChatInput.backgroundColor = UIColor.royalPurple
        //imgvwMessageSendBG.image = UIImage(named: "background-chat-bar")
        leadingSpacingChatInputConstraint.constant = 40
        traillingSpacingChatInputConstraint.constant = leadingSpacingChatInputConstraint.constant
        constraintHeightChatInput.constant = 35
        constraintWidthOfPaperClip.constant = 0
        
        vwAttachButtons.isHidden = true
        btnSendMessage.isHidden = false
        btnSendMessage.setImage(UIImage(named: "sendBtn"), for: .normal)
        
        txtSendChatMessage.textColor = .white
        txtSendChatMessage.placeholderColor = UIColor.white
        btnSendMessage.isHidden = false
        btnPaperClip.isHidden = true
        vwBlackOverlay.isHidden = true
    }
    func setChatInputsOnShowKeyboard()
    {
        isKeyboardHide = false
        vwChatInput.backgroundColor = UIColor.white
        leadingSpacingChatInputConstraint.constant = 14
        traillingSpacingChatInputConstraint.constant = leadingSpacingChatInputConstraint.constant
        
        //imgvwMessageSendBG.image = UIImage(named: "chatInputBackground_white")
//        vwAttachButtons.isHidden = false
        
        txtSendChatMessage.textColor = .black
        txtSendChatMessage.placeholderColor = UIColor.lightGray
        
        vwBlackOverlay.isHidden = false
        
        if txtSendChatMessage.text.count > 0
        {
            btnPaperClip.isHidden = false
            constraintWidthOfPaperClip.constant = 35
            vwAttachButtons.isHidden = true
            btnSendMessage.isHidden = false
            btnSendMessage.setImage(UIImage(named: "send"), for: .normal)
        }
        else
        {
//            bottomView.viewTxtChat.layer.borderColor = UIColor.slateGrey.cgColor
//            resetStackButton()
            btnPaperClip.isHidden = true
            constraintWidthOfPaperClip.constant = 0
            vwAttachButtons.isHidden = false
            btnSendMessage.isHidden = true
            btnSendMessage.setImage(UIImage(named: "sendBtn"), for: .normal)
        }
    }
    func didPressAattechmentBtn()
    {
        let chatView = MatchesChatViewVC()
        // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
        let jidString = URLHandler.userPreFix + "\(match.id)@" + URLHandler.xmpp_domain
        OneChats.addUserToChatList(jidStr: jidString, displayName: match.name)
        Thread.sleep(forTimeInterval: 1.0)
        let user = OneRoster.userFromRosterForJID(jid: URLHandler.userPreFix + match.id + URLHandler.xmpp_domainResource)
        chatView.recipientXMPP = user
        chatView.matchObject = match
        chatView.isFromMatchVC = true
        chatView.selectedMessageTypeFromMatch = .paperClip
        chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: jidString, senderDisplayName: "")

        if user != nil {
            // Check to make sure that the user is there
            if isPresented{
                weak var pvc = self.presentingViewController
                self.dismiss(animated: true, completion: {
                    let chatNavigationController = UINavigationController(rootViewController: chatView)
                    chatNavigationController.modalPresentationStyle = .fullScreen
                    pvc?.present(chatNavigationController, animated: true, completion: nil)
                })
            }
            else{
                self.navigationController?.pushViewController(chatView, animated: true)
            }
        } else {
            // Present messages that there is a network error to the server
        }
    }
    
    //MARK: - Button Actions

    @IBAction func btnBack(_ sender: Any) {
        /*let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false)*/
        self.navigationController?.popViewController(animated: false)
        self.dismiss(animated: true)
    }
    @IBAction func keepSwiping(_ sender: AnyObject) {
        if isFromGoing {
            btnBack(1)
        } else {
            self.navigationController?.popViewController(animated: false)
            self.dismiss(animated: true)
        }
        // TODO when this view was added a childviewcontroller was added. has to be removed.
    }
    
    //MARK: - Keyboard handle events
    @objc func keyBoardWillShow(notification: NSNotification) {
        //handle appearing of keyboard here
        //print("Keyboard open")
        setChatInputsOnShowKeyboard()
        
    }


    @objc func keyBoardWillHide(notification: NSNotification) {
        //handle dismiss of keyboard here
        //print("Keyboard close")
        setChatInputsOnHideKeyboard()

    }
    //MARK: - Scrollview mthods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.y/scrollView.frame.height)
       
        selectedIdx = Int(pageIndex)
        pageCollView.reloadData()
    }
    //MARK: - Chat buttons other methods
    func actionSheetResponse(_ sender: String) {
        switch sender {
        case "camera":
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = false
                imagePicker.modalPresentationStyle = .overCurrentContext
                self.present(imagePicker, animated: true, completion: nil)
            }
        case "gallery":
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
                
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        case WebKeyhandler.Location.location:
            //print("Message send clicked")
            let chatView = MatchesChatViewVC()
            // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
            let jidString = URLHandler.userPreFix + "\(match.id)@" + URLHandler.xmpp_domain
            OneChats.addUserToChatList(jidStr: jidString, displayName: match.name)
            Thread.sleep(forTimeInterval: 1.0)
            let user = OneRoster.userFromRosterForJID(jid: URLHandler.userPreFix + match.id + URLHandler.xmpp_domainResource)
            chatView.recipientXMPP = user
            chatView.matchObject = match
            chatView.isFromMatchVC = true
            chatView.selectedMessageTypeFromMatch = .location
            chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: jidString, senderDisplayName: "")

            if user != nil {
                // Check to make sure that the user is there
                if isPresented{
                    weak var pvc = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        let chatNavigationController = UINavigationController(rootViewController: chatView)
                        chatNavigationController.modalPresentationStyle = .fullScreen
                        pvc?.present(chatNavigationController, animated: true, completion: nil)
                    })
                }
                else{
                    self.navigationController?.pushViewController(chatView, animated: true)
                }
            } else {
                // Present messages that there is a network error to the server
            }
            //print("Location send from here")
        case "Unmatch":
            break
            //print("Unmatch")
        case "Unmatch&Report":
            break
            //print("Unmatch&Report")
        default:
            break
            // Last Message
            //print("Cancel")
        }
    }

    
    //MARK: - Chat attach buttons actions
    
    @IBAction func btn_camera(_ sender: UIButton) {
        actionSheetResponse("camera")
    }
    @IBAction func btn_gallery(_ sender: UIButton) {
        actionSheetResponse("gallery")
    }
    @IBAction func btn_location(_ sender: UIButton) {
        actionSheetResponse(WebKeyhandler.Location.location)
    }
    @IBAction func btn_paperClip(_ sender: UIButton) {
       
        didPressAattechmentBtn()
    }
    @IBAction func sendMessage(_ sender: AnyObject)
    {
        //print("Message send clicked")
        let chatView = MatchesChatViewVC()
        // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
        let jidString = URLHandler.userPreFix + "\(match.id)@" + URLHandler.xmpp_domain
        OneChats.addUserToChatList(jidStr: jidString, displayName: match.name)
        Thread.sleep(forTimeInterval: 0.1)
        let user = OneRoster.userFromRosterForJID(jid: URLHandler.userPreFix + match.id + URLHandler.xmpp_domainResource)
        chatView.recipientXMPP = user
        chatView.matchObject = match
        chatView.isFromMatchVC = true
        chatView.strMessageFromMatchVC = txtSendChatMessage.text
        chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: jidString, senderDisplayName: "")

        if user != nil {
            // Check to make sure that the user is there
            if isPresented{
                weak var pvc = self.presentingViewController
                self.dismiss(animated: true, completion: {
                    let chatNavigationController = UINavigationController(rootViewController: chatView)
                    chatNavigationController.modalPresentationStyle = .fullScreen
                    pvc?.present(chatNavigationController, animated: true, completion: nil)
                })
            }
            else{
                self.navigationController?.pushViewController(chatView, animated: true)
            }
        } else {
            // Present messages that there is a network error to the server
        }
    }
}
//MARK: - Image picker methods
// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
extension MatchVC
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let originalImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage)
        // can be used in future to get localIdentifier
        // let identifier = (info[UIImagePickerController.InfoKey.phAsset.rawValue] as? PHAsset)?.localIdentifier
        
        // Find size of image to set scaling
        let originalImageHeight = originalImage.size.height
        let originalImageWidth = originalImage.size.width
        var scaledImageWidth = CGFloat()
        var scaledImageHeight = CGFloat()
        if originalImageHeight  >= 1000 && originalImageHeight >= originalImageWidth { // if the size of height is more than 1000 px and picture is higher than wide
            scaledImageHeight = CGFloat(1000)
            scaledImageWidth = originalImageWidth / (originalImageHeight / scaledImageHeight) // calculates the new width of the image based on the factors from the original to the scaled image
        } else if originalImageWidth >= 1000 && originalImageWidth >= originalImageHeight { // if the size of width is more than 1000 px and picture is wider than high
            scaledImageWidth = CGFloat(1000)
            scaledImageHeight = originalImageHeight / (originalImageWidth / scaledImageWidth) // calculates the new height of the image based on the factors from the original to the scaled image
        } else {                            // If both height or width is not over 1000
            scaledImageHeight = originalImageHeight
            scaledImageWidth = originalImageWidth
        }
        
        let imageSize = CGSize.init(width: scaledImageWidth, height: scaledImageHeight)
        let scaledImage = originalImage.af.imageScaled(to: imageSize)
        send(image: scaledImage)
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
//MARK: - Message send to chat
extension MatchVC
{
    func send(image: UIImage)
    {
        //print("Redirection to chat screen with sent message from here")
        //print("Message should be send from here")
        
        let chatView = MatchesChatViewVC()
        // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
        let jidString = URLHandler.userPreFix + "\(match.id)@" + URLHandler.xmpp_domain
        OneChats.addUserToChatList(jidStr: jidString, displayName: match.name)
        let user = OneRoster.userFromRosterForJID(jid: URLHandler.userPreFix + match.id + URLHandler.xmpp_domainResource)
        chatView.recipientXMPP = user
        chatView.matchObject = match
        chatView.isFromMatchVC = true
        chatView.selectedMessageTypeFromMatch = .image
        chatView.imageMessage = image
        chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: jidString, senderDisplayName: "")

        if user != nil {
            // Check to make sure that the user is there
            if isPresented{
                weak var pvc = self.presentingViewController
                self.dismiss(animated: true, completion: {
                    let chatNavigationController = UINavigationController(rootViewController: chatView)
                    chatNavigationController.modalPresentationStyle = .fullScreen
                    pvc?.present(chatNavigationController, animated: true, completion: nil)
                })
            }
            else{
                self.navigationController?.pushViewController(chatView, animated: true)
            }
        } else {
            // Present messages that there is a network error to the server
        }
       
        
        
        /*let main = MainController() as MainController
        
        let sender = ChatUserObject(senderId: currentSender().senderId, displayName: currentSender().displayName)
        let photoMessage = MessageObject(image: image, sender: sender, messageId: messageIdInNewMessage, date: Date())
        
        main.uploadImage(image) { (dictionary) in
            if let photoUrl = dictionary["url"] {
                OneMessage.sendMessage(message: photoUrl as! String, to: (self.recipientXMPP?.jidStr)!, is: WebKeyhandler.Chat.xmppPhoto, completionHandler: { (_, completeMessage) -> Void in
                    // grab the newly cereated messageID from a new message, it will serve later to delete image message right after it has been sent using a unique messageID
                    if let tempMessageId = completeMessage.attributeStringValue(forName: "id") {
                        // retract message has "retract-message-1" as id, in that case messageId of the messageList array doesn't need to be updated. This is realy important when you delete the last image message in the chat
                        if self.messageList.count != 0 {
                            self.messageIdInNewMessage = tempMessageId
                            self.messageList[self.messageList.count-1].messageId = self.messageIdInNewMessage
                        }
                    }
                    self.messageIdInNewMessage = ""
                })
            }
        }
        
        self.messageList.append(photoMessage)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: true)
        self.addOrRemoveEncouragementView()*/
    }
}
//MARK: - Next scroll delegates
extension MatchVC : pageNextDelegate
{
    func gotoNextPage()
    {
        /*cTime = 0
        if selectedIdx == (arrayMatchTitles.count - 1) {
            selectedIdx = 0
        } else {
            selectedIdx += 1
        }
        lblMatchName.text = arrayMatchTitles[selectedIdx]
        makeNextScreenVisible()
        //scrollView.scrollRectToVisible(visibleImageView.frame, animated: true)
        pageCollView.reloadData()*/
    }
    
    func getCurrentTime(_ time: Float)
    {
        cTime = time
    }
    
    
}
//MAR: - Textview methods
extension MatchVC: UITextViewDelegate
{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if(textView.text.count > 0)
        {
            setChatInputsOnShowKeyboard()
        }
        else{
            setChatInputsOnHideKeyboard()
        }
        return true
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let searchText : String = textView.text ?? ""
        if searchText.count == 0
        {
            //resetStackButton()
        }
    }
    func textViewDidChange(_ textView: UITextView)
    {
        let searchText : String = textView.text ?? ""
        let numLines : CGFloat = (textView.contentSize.height / (textView.font?.lineHeight ?? 20))
        manageHeight(Int(numLines))
        if searchText.count > 0
        {
            vwAttachButtons.isHidden = true
            btnSendMessage.isHidden = false
            btnPaperClip.isHidden = false
            constraintWidthOfPaperClip.constant = 35
            btnSendMessage.setImage(UIImage(named: "send"), for: .normal)
        }
        else
        {
            btnPaperClip.isHidden = true
            constraintWidthOfPaperClip.constant = 0
            vwAttachButtons.isHidden = false
            btnSendMessage.isHidden = true
            btnSendMessage.setImage(UIImage(named: "sendBtn"), for: .normal)
        }
    }
    func manageHeight(_ numLines : Int) {
        let lineCount : Int = (numLines > 5) ? 5 : numLines
        let window = UIApplication.shared.windows.first
        let bottomPadding : CGFloat = window?.safeAreaInsets.bottom ?? 0
        let height : CGFloat = 45 + bottomPadding + CGFloat((lineCount * 18))
        let width : CGFloat = window?.frame.width ?? 0
        y = (window?.frame.height ?? 0) - height
//        vwChatInput.frame = CGRect(x: 0, y: y - self.keyboardHeight, width: width, height: height)
        
        if(isKeyboardHide)
        {
            constraintHeightChatInput.constant = 35
        }else{
            if(numLines == 1)
            {
                constraintHeightChatInput.constant = 35
            }else{
                constraintHeightChatInput.constant = 35 + CGFloat((lineCount * 18))
            }
        }
    }
}
//MARK: - Collectionview methods
extension MatchVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayMatchTitles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageControllCollCell", for: indexPath)
        if let view = cell as? PageControllCollCell {
            if selectedIdx == indexPath.item && arrayMatchTitles.count > 1  {
                view.delegate = self
                view.timer?.invalidate()
                view.timer = nil
                view.startTimer(cTime)
            } else {
                view.timer?.invalidate()
                view.pageView.progress = cTime
                if cTime == 0 {
                    view.timer = nil
                }
            }
            view.pageView.isHidden = (selectedIdx == indexPath.item) ? false : true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 10, height: 10)
    }
    /*func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets
    {
        let totalWidth = 10 * arrayMatchTitles.count
        let totalSpacingWidth = 10 * (arrayMatchTitles.count - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }*/
}
