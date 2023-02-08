//
//  MatchProfilePreviewVC.swift
//  Krown
//
//  Created by Mac Mini 2020 on 17/05/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI
import Koloda
import SDWebImage
import MBProgressHUD
import Alamofire

class KolodaSwipeProfilesVC: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    var isFromGoing : Bool = false
    @IBOutlet weak var kolodaView: KolodaView!
    var profileInfo: [PersonObject] = []
    var mainController: MainController = MainController()
//    var id : String?
    var mainProfileInfoMatchModel = [MatchesModel]()
    var profileInfoMatchModel : [MatchesModel] = []
    
    // var isBackFromEdit = Bool()
    private var isReloadingData = false
    var kolodaViewNumberOfCards = 0
    var viewType : viewtype?
    var strTitle = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = strTitle
//        kolodaView.isLoop = true
        // isBackFromEdit = false
        globalConstant.isDissmiss = false
        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            self.kolodaView.dataSource = self
            self.kolodaView.delegate = self
            setupKolodaView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edgesForExtendedLayout = UIRectEdge.bottom
        extendedLayoutIncludesOpaqueBars = true
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if globalConstant.isDissmiss == true {
            self.navigationController?.popViewController(animated: true)
        }

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
      //  tabBarController!.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844);
        MBProgressHUD.hide(for:self.view, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
//        self.kolodaViewNumberOfCards = 1
//        self.kolodaView.resetCurrentCardIndex()
    }
    func setupKolodaView() {
        self.view.addSubview(kolodaView)
        self.view.bringSubviewToFront(kolodaView)
    }
    
    @IBAction func bckAction(_ sender: Any) {
        //TODO: - do stuff here
        navigateToBack()
       // self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnEdit(_ sender: Any) {
        let swiftUIView = ProfileView()
        globalConstant.isDissmiss = true
        //  isBackFromEdit = true
        let homeViewController = UIHostingController(rootView: swiftUIView)
//        homeViewController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    func navigateToBack(){
        let profileMatchObject = mainProfileInfoMatchModel
        mainProfileInfoMatchModel = profileMatchObject
        NotificationCenter.default.post(name: .changePeopleList,object: nil,userInfo: ["newList" : mainProfileInfoMatchModel])
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: { [self] in
            self.dismiss(animated: true)
        })
    }
    
    func checkForNavigation(index : Int){
        if profileInfo.count - index <= 1 {
            navigateToBack()
        }
    }
}
extension KolodaSwipeProfilesVC: KolodaViewDelegate {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        let view = Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
        let dict = profileInfo[index]
        view?.isHidden = ( viewType == .matchesGoingView || dict.matched == "1") ? true : false
        return view
    }
}
extension KolodaSwipeProfilesVC: KolodaViewDataSource {
    
    public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        //return kolodaViewNumberOfCards
        return profileInfo.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt cardIndex: Int) -> UIView {
        // BUG: if swiping really fast while reloading the cardIndex becomes -1 and this creates an out of range fatal error
        let swipeDetailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swipeDetailView") as! SwipeDetailVC
        swipeDetailView.swipeInfo = profileInfo[cardIndex]
        addChild(swipeDetailView)
        globalConstant.isPreviewScreen = true
        swipeDetailView.view.layer.cornerRadius = 20
        swipeDetailView.isFromHome = false
        swipeDetailView.viewDialogWave.isHidden = true
        globalConstant.isSwipeWave = false
        
        let dict = profileInfo[cardIndex]
        
        //Defining what is specific to viewtype (.allReadyGoingView is MatchesGoingView)
        if viewType == .matchesGoingView{
            swipeDetailView.dislikeButton.isHidden = true
            swipeDetailView.likeButton.isHidden = true
            swipeDetailView.waveButton.setImage(UIImage(named: "msg"), for: .normal)
            swipeDetailView.buttonAction = { [self] sender in
                globalConstant.isSwipeWave = false
                generateMatchObjectForChat(profile: dict)
            }
        }
        
        //Defining specific parts of view for viewtype
        if viewType == .goingView{
            swipeDetailView.dislikeButton.isHidden = true
            swipeDetailView.likeButton.isHidden = true
            swipeDetailView.waveButton.setImage(UIImage(named: "wave"), for: .normal)
            swipeDetailView.buttonAction = { [self] sender in
                if UserDefaults.standard.bool(forKey: WebKeyhandler.User.isWaveUsedUp){
                    showWaveUsedUpPopUp(viewController: self, callback: { bool in
                        if bool {
                            globalConstant.isSwipeWave = true
                            kolodaView.swipe(.right)
                        }
                    })
                }
                else{
                    globalConstant.isSwipeWave = true
                    kolodaView.swipe(.right)
                }
            }
        }
        
        //Defining specific parts of view for viewtype
        if viewType == .waveView {
            swipeDetailView.dislikeButton.isHidden = true
            swipeDetailView.likeButton.isHidden = true
        }
        
        //Defining specific parts of view for viewtype
        if viewType == .nearbyView {
            swipeDetailView.dislikeButton.isHidden = true
            swipeDetailView.likeButton.isHidden = false
        }
        
        //Defining what is general to viewtype .goingView .waveView .nearbyView
        if viewType == .goingView || viewType == .waveView || viewType == .nearbyView {
            if dict.matched == "1" {
                swipeDetailView.dislikeButton.isHidden = true
                swipeDetailView.likeButton.isHidden = true
                swipeDetailView.waveButton.setImage(UIImage(named: "msg"), for: .normal)
                swipeDetailView.buttonAction = { [self] sender in
                    globalConstant.isSwipeWave = false
                    generateMatchObjectForChat(profile: dict)
                }
            } else
            {
                if viewType == .waveView || viewType == .nearbyView{
                    swipeDetailView.waveButton.setImage(UIImage(named: "like"), for: .normal)
                    swipeDetailView.buttonAction = { [self] sender in
                        globalConstant.isSwipeWave = false
                        kolodaView.swipe(.right)
                    }
                }
            }
            
        } else
        {
            swipeDetailView.waveButton.setImage(UIImage(named: "wave"), for: .normal)
        }
        
        swipeDetailView.createScrollView(viewSize: kolodaView.frameForCard(at: 0))
        
        addChild(swipeDetailView)
        
        return swipeDetailView.view
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.isHidden = true
        if viewType == .matchesGoingView{
            navigateToBack()
        }
        
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let profile = profileInfo[index]
        //Defining specific actions for viewtype
        var allowRightSwipe : Bool = false
        var allowLeftSwipe : Bool = false
        
        if viewType == .goingView {
            //Allow liking
            allowRightSwipe = true
            allowLeftSwipe = true
        }
        
        //Defining specific actions for viewtype
        if viewType == .waveView {
            //Allow liking
            allowRightSwipe = true
            allowLeftSwipe = true
        }
        
        //Defining specific actions for viewtype
        if viewType == .nearbyView && profile.matched == "1" {
            //Is a match
            //Liking not allowed
            checkForNavigation(index: index)
        } else
        //Defining specific actions for viewtype
        if (viewType == .nearbyView && profile.matched != "1") {
            allowRightSwipe = true
        }
        
        // Actions
        if direction == SwipeResultDirection.right && allowRightSwipe {
            likeUser(profile: profileInfo[index], index: index, profilesModel: profileInfoMatchModel[index])
        }
        
        if direction == SwipeResultDirection.left && allowLeftSwipe {
            if globalConstant.isFlagSwipeAction == false {
                disLikeUser(profile: profileInfo[index], index: index, profilesModel: profileInfoMatchModel[index])
            } else
            {
                globalConstant.isFlagSwipeAction = false
            }
        }
        
        if profileInfo.count-index == 1{
            let profileMatchObject = profileInfoMatchModel
            profileInfoMatchModel = profileMatchObject
        }
        
        self.navigationController?.popViewController(animated: true)
        // Spins the arrow in the menu
        
    }

    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func generateMatchObjectForChat(profile : PersonObject){
        let interestDict = profile.interests
        var interests: [InterestModel] = []
        for index in 0..<interestDict.count {
      
            let dict = interestDict[index]
            let interest: String = dict.interest!
            let common: String = dict.common!
            let interest_id: String = dict.interest_id!
            let member_id: String = dict.member_id!
            let isSelected: Bool = dict.isSelected!
        
            interests.append( InterestModel(common: common, interest: interest, interest_id: interest_id, member_id: member_id, isSelected: isSelected) )
            
        }
        let matchObject : MatchObject = MatchObject.init(id: profile.id , name: profile.name , imageArray:  (profile.imageArray.count ) > 0 ? [profile.imageArray[0] ] : [""], lastActiveTime: "", distance: profile.distance , interests: interests)
        
        self.navigateToMatchChat(matchObject: matchObject,imgYouUSer: (profile.imageArray.count ) > 0 ? profile.imageArray[0]  : "" )
    }
    
    func navigateToMatch(matchObject : MatchObject){
        MBProgressHUD.hide(for:self.view, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard let matchVC = storyboard.instantiateViewController(
                    identifier: "MatchVC") as? MatchVC else {
                fatalError("Cannot load from storyboard")
            }
        matchVC.isFromGoing = true
        matchVC.isPresented = true
        matchVC.match = matchObject
        
        let matchNavigationController = UINavigationController(rootViewController: matchVC)
        matchNavigationController.modalPresentationStyle = .overCurrentContext
        self.present(matchNavigationController, animated: true)
        
    }
    
    func navigateToMatchChat(matchObject : MatchObject, imgYouUSer : String){
        let chatView = MatchesChatViewVC()
      
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
//        chatView.isFromSwiftUI = true
        var headers: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            headers = [.authorization(bearerToken: "ForceRefresh"),]
        }
        AF.request(imgYouUSer , method: .get, headers: headers).responseImage { response in
            if case .success(let image) = response.result {
                chatView.imgYouUser = image
            }
        }
        chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: "krownuser_\(matchObject.id)@" + URLHandler.xmpp_domain, senderDisplayName: matchObject.name)
        
        let chatNavigationController = UINavigationController(rootViewController: chatView)
        chatNavigationController.modalPresentationStyle = .overCurrentContext
        self.present(chatNavigationController, animated: true)
    }
    
    func likeUser( profile : PersonObject, index : Int, profilesModel : MatchesModel){
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        MBProgressHUD.showAdded(to: self.view, animated: true)
        mainController.swipeAction(thisUserID, action: globalConstant.isSwipeWave ? 5 : 1, swipeCardID: profile.id) { [self] (response) in
            let wave : [String:Any] = response["Waves"] as? [String:Any] ?? [:]
            setWaveUsedUp(wave: wave)
            if (response["ErrorCode"]! as! String) == "47" || (response["ErrorCode"]! as! String) == "InviteAction done"{
                //kolodaView.swipe(SwipeResultDirection.right )
                if let _ : NSDictionary = response["match"] as? NSDictionary
                {
                    mainController.generateMatch(personDict: response, callback: { (match) in
                        MBProgressHUD.hide(for:self.view, animated: true)

                        if let idx = mainProfileInfoMatchModel.firstIndex(where: { $0  == profilesModel}) {
                            mainProfileInfoMatchModel[idx].matched = "1"
                        }
                        let matchObject : MatchObject = MatchObject.init(id: match.id , name: match.name , imageArray: match.imageArray  , lastActiveTime: "", distance: match.distance , interests: match.interests)
                        self.navigateToMatch(matchObject: matchObject)
                    })
                } else {
                    mainProfileInfoMatchModel = mainProfileInfoMatchModel.filter( { $0 != profilesModel } )
                    checkForNavigation(index: index)
                    
                    if self.profileInfo.count == 0 {
                        self.dismiss(animated: true)
                    }
                    MBProgressHUD.hide(for:self.view, animated: true)
                }
            } else {
                checkForNavigation(index: index)
                MBProgressHUD.hide(for:self.view, animated: true)
            }
           
        }
    }
    
    func disLikeUser( profile : PersonObject, index : Int, profilesModel : MatchesModel){
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        MBProgressHUD.showAdded(to: self.view, animated: true)
        mainController.swipeAction(thisUserID, action: 2, swipeCardID: profile.id) { [self] (response) in
            if (response["ErrorCode"]! as! String) == "47" || (response["ErrorCode"]! as! String) == "InviteAction done"{
                mainProfileInfoMatchModel = mainProfileInfoMatchModel.filter( { $0 != profilesModel } )
                checkForNavigation(index: index)
            } else {
                checkForNavigation(index: index)
                MBProgressHUD.hide(for:self.view, animated: true)
            }
        }
    }
    

}

