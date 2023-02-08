//
//  HomeVC.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import Koloda
import QuartzCore
import XMPPFramework
import Foundation
import SwiftLocation
import FirebaseCrashlytics
import SDWebImage
import SwiftEntryKit
import MBProgressHUD

private var isReloadingData = false
class HomeVC: UIViewController, OneChatDelegate, OneMessageDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    public func oneStream(sender: XMPPStream, composingUser: XMPPUserCoreDataStorageObject, userIsComposing: Bool) {
    }
    public func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject, ofType type: String) {
        // TODO: Figure out if this belongs here and figure out if this will open in all situations
        if type == WebKeyhandler.Chat.xmppMatch { // Info: If a user swipes another user while the app is open a message is sent. This open a match window.
            let userID = String(describing: user.jidStr!.slice(from: "_", to: "@"))
            MainController().getProfile(userID: userID, callback: { (personObject) in
                let match = MatchObject(id: personObject.id, name: personObject.name, imageArray: personObject.imageArray, lastActiveTime: String(describing: Date()), distance: personObject.distance, interests: [InterestModel]())
                self.showMatchVC(match: match)
                })
            }
    }
    public func oneStreamDidDisconnect(sender: XMPPStream, withError error: NSError) {
    }
    public func oneStream(sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
    }
    public func oneStreamDidAuthenticate(sender: XMPPStream) {
    }
    public func oneStreamDidConnect(sender: XMPPStream) {
    }
    public func oneStream(sender: XMPPStream?, socketDidConnect socket: GCDAsyncSocket?) {
    }
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    @IBOutlet weak var vwPause: UIView!
    @IBOutlet weak var accountStatusBrif: UILabel!
    
    @IBOutlet weak var top2: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceNoPeopleLogoConstraint: NSLayoutConstraint!

    @IBOutlet weak var vwNoPerson: UIView!
    @IBOutlet weak var btnFintEvent: UIButton!
    @IBOutlet weak var emptyStateSubtext: UILabel!
    @IBOutlet weak var btnMyDiscoveryFilter: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    
    
    @IBOutlet weak var hiddenRightFullscreenOverlay: UIButton!
    @IBOutlet weak var reloadMatchesBtnOutlet: UIButton!
    @IBOutlet weak var hiddenLeftFullScreenOverlay: UIButton!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var lookingForKrowners: UILabel!
    @IBOutlet weak var krownLogo: UIView!
    @IBOutlet weak var krownCircleLogo: UIImageView!
//    @IBOutlet weak var imgvwKrownLogoLastCard: UIImageView!

    @IBOutlet weak var vwPersonisLiveAtLocation: UIView!
    @IBOutlet weak var vwDiscoverHub: UIView!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var btnNearby: UIButton!
    @IBOutlet weak var bottomSpaceVwDiscoverHub: NSLayoutConstraint!
    
    var dataSourceArr: [PersonObject] = []
    var mainController: MainController = MainController()
    var allowSwipesRefresh = false
    let searchingString = "Looking for Krowners"
    let noneFoundString = "No Krowners found, change scope or try again later"
    var timer : Timer?
    var activateTimer : Timer?
    private var differenceInSeconds = Int()
    
    
    func swipeLeft() {
        globalConstant.isSwipeWave = false
        kolodaView.swipe(SwipeResultDirection.left)
    }

    func swipeRight() {
        globalConstant.isSwipeWave = false
        kolodaView.swipe(SwipeResultDirection.right )
    }
    func swipeWaveRight() {
        if UserDefaults.standard.bool(forKey: WebKeyhandler.User.isWaveUsedUp){
            showWaveUsedUpPopUp(viewController: self, callback: { [self] bool in
                if bool{
                    globalConstant.isSwipeWave = true
                    kolodaView.swipe(SwipeResultDirection.right )
                }
            })
        }
        else{
            globalConstant.isSwipeWave = true
            kolodaView.swipe(SwipeResultDirection.right )
        }
    }

    
    func initialSetup()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        vwPersonisLiveAtLocation.addGestureRecognizer(tap)

         
//        imgvwKrownLogoLastCard.isHidden = true
        btnFintEvent.isHidden = true
        emptyStateSubtext.text = "Try refreshing or changing your filters."
        btnRefresh.makeButtonRound()
        
        topSpaceConstraint.constant = UIScreen.main.bounds.height * 0.18
//        topSpaceConstraint.constant = (UIScreen.main.bounds.height * 186)/736

        topSpaceNoPeopleLogoConstraint.constant = topSpaceConstraint.constant
        
        btnFintEvent.layer.cornerRadius = btnFintEvent.frame.size.height/2
        btnMyDiscoveryFilter.layer.cornerRadius = btnMyDiscoveryFilter.frame.size.height/2
        
        var header : String
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            header = UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String
        } else {
            header = "ForceRefresh"
        }
        SDWebImageDownloader.shared.setValue("Bearer \(header)", forHTTPHeaderField: "authorization")

        showKrownSearchLogo()

        locationHandling()

        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)

        // Get Facebook events and push them to server
        let userController = UserController()
        userController.getFacebookEventsArray(graphPath: "", parameters: ["": ""])// Should be empty

        // Get and push the users friends to server
        userController.getCurrentUsersFriends()

        // Add observer for resetting dataSource
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.resetAndRefreshDataSource),
            name: .resetAndRefreshDataSourceForSwipes,
            object: nil)

        // Setup chat delegate
        OneChat.sharedInstance.delegate = self

        // Setup of KolodaView datasouce and delegate
        kolodaView.dataSource = self
        kolodaView.delegate = self

        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        // Setup connection to xmpp chat server
        connectToXMPPChatServer()
        
        
        //Show discover hub toolbar and enable it
        //showDiscoverHUBView()
    }
    
    func locationHandling() {
        LocationController.shared.initiateLessPreciseTracking()
        LocationController.shared.intiateGeofences()
        
        // Check if location is authorized, if not display location pop up
        switch SwiftLocation.authorizationStatus {
        case .denied,
             .notDetermined,
             .restricted:
            //print("The user has changed permission and stopped authorizing location")
            // TODO: If a user changes the permission for location to either above then it goes into a loop that leads to a memory issue and crash
            //print("The user has not authorized location")
            self.displayLocationPopup()
        case .authorizedAlways,
             .authorizedWhenInUse:
            
            SwiftLocation.allowsBackgroundLocationUpdates = true
            SwiftLocation.pausesLocationUpdatesAutomatically = true
            // For refreshing the service once the location has been set. It fires on every load
            self.mainController.getLocation(2, forceGetLocation: true, withAccuracy: .city) { (locationDict) in
                    self.mainController.sendLocation(locationDict, callback: { (_) in
                        self.reloadDataSource(swipedCardAtIndex: 0)
                    })
                }
        default:
        //print("The user has not authorized location")
        self.displayLocationPopup()
        }
    }
    
    func connectToXMPPChatServer() {
        // Logic: If disconnected->Connect->if fail->register->connect again.

        if OneChat.sharedInstance.isConnected() {
            //print("Connection to XMPP was established, chat is now active.")
        } else {
            // Connection attempt
            let username: String = UserDefaults.standard.object(forKey: UserDefaultsKeyHandler.Login.userLogin)! as! String
            let chosenPassword: String = UserDefaults.standard.object(forKey: "userPassword") as! String
            //print("Login is attempted")

            OneChat.sharedInstance.connect(username: username, password: chosenPassword) { (_, error) -> Void in
                // if error register and connect
                if let _ = error {

                    OneChat.sharedInstance.register(username: username, password: chosenPassword, completionHandler: { (_, error) in

                        if let _ = error {
                            let alertController = UIAlertController(title: "Sorry", message: "A chat error occured: \(String(describing: error!))", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (_) -> Void in
                            }))
                            self.present(alertController, animated: true, completion: nil)
                        }

                    })
                } else {

                    //print("Connection to XMPP was established, chat is now active.")
                }
            }
        }
    }
    //MARK:- Life cycle methods
    override func viewDidLoad() {

        //These at live and not at live notification are potentially unused at the moment. If we later want to only show based on whether a user is live or not these can be listened to.
        //NotificationCenter.default.addObserver(self, selector: #selector(atLiveLocation(notification:)), name:  .personAtLiveLocation, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(notAtLiveLocation(notification:)), name: .personNotAtLiveLocation, object: nil)
        
        //Highlight the correct buttons.
        NotificationCenter.default.addObserver(self, selector: #selector(setNerabyButtonActive(notification:)), name: .setNearbyActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setPeopleButtonActive(notification:)), name: .setPeopleActive, object: nil)
        
        //These two notifications have been set to hide or show the discover nearby menu based on distance from location
        NotificationCenter.default.addObserver(self, selector: #selector(atLiveLocation(notification:)), name: .allowShowingDiscoverNearby, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notAtLiveLocation(notification:)), name: .disallowShowingDiscoverNearby, object: nil)
        
        
        
        setupButtonUI()
        // Crashlytics.sharedInstance().setObjectValue("HomeVC", forKey: "Screen")
        // Answers.logLogin(withMethod: "Normal", success: true, customAttributes: [:])
         // Loading animation
        initialSetup()
        setupPauseView()
        getPreferences()
    }
    


    override func viewWillAppear(_ animated: Bool) {
      //  super.viewWillAppear(true)
//    resetAndRefreshDataSource()
        tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.layer.zPosition = 0
        tabBarController?.tabBar.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.items?.forEach { $0.isEnabled = true }
        self.tabBarController?.tabBar.frame = UITabBarController().tabBar.frame
        self.tabBarController?.tabBar.alpha = 1
        kolodaView.reloadData()
        self.view.layoutSubviews()
        bottomSpaceVwDiscoverHub.constant = 0
        //getPreferences()
        setPeopleButtonUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        hideDiscoverHUBView()
    }
 
    override func viewDidLayoutSubviews() {
        kolodaView.layoutSubviews()
        kolodaView.layoutIfNeeded()
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
    }
    //MARK: - Discover hub business logic
    @objc func atLiveLocation(notification : Notification){
        if vwPause.isHidden {
            showDiscoverHUBView()
        }
    }
    @objc func notAtLiveLocation(notification : Notification){
        hideDiscoverHUBView()
    }
    
    func showDiscoverHUBView()
    {

        globalConstant.isToolbarVisible = true
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hideToolBar), userInfo: nil, repeats: false)
        bottomSpaceVwDiscoverHub.constant = 0
        DispatchQueue.main.async { [self] in
            self.vwDiscoverHub.animShow(secondaryView: self.vwPersonisLiveAtLocation, bottomConstraint: bottomSpaceVwDiscoverHub)
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "Compass Selected straigth")
        }
        
    }
    
    @objc func hideToolBar(){
        hideDiscoverHUBView()
    }
    
    
    func hideDiscoverHUBView(){
        timer?.invalidate()
        globalConstant.isToolbarVisible = false
        DispatchQueue.main.async { [self] in
            vwDiscoverHub.animHide(secondaryView: vwPersonisLiveAtLocation, bottomConstraint: bottomSpaceVwDiscoverHub)
            self.tabBarController?.tabBar.items![1].image = UIImage(named: "Compass Selected")
        }
        
    }
    
    func setupButtonUI(){
        btnPeople.alignTextUnderImage()
        btnNearby.alignTextUnderImage()
    }
    
    @IBAction func btnDiscoverHubClicked(_ sender: UIButton) {
        if sender.tag == 0{
            setPeopleButtonUI()
            //show cards
            hideDiscoverHUBView()
            kolodaView.resetCurrentCardIndex()
        }
        else{
            setNearbyButtonUI()
            hideDiscoverHUBView()
            redirectToNearBy()
        }
    }
    
    func setPeopleButtonUI(){
        btnPeople.backgroundColor = .winterSky
        btnPeople.setTitleColor(.royalPurple, for: .normal)
        btnPeople.tintColor = .royalPurple
        
        btnNearby.backgroundColor = .white
        btnNearby.setTitleColor(.slateGrey, for: .normal)
        btnNearby.tintColor = .slateGrey
    }
    
    func setNearbyButtonUI(){
        btnNearby.backgroundColor = .winterSky
        btnNearby.setTitleColor(.royalPurple, for: .normal)
        btnNearby.tintColor = .royalPurple
        
        btnPeople.backgroundColor = .white
        btnPeople.setTitleColor(.slateGrey, for: .normal)
        btnPeople.tintColor = .slateGrey
    }
    
    @objc func setNerabyButtonActive(notification : Notification){
        setNearbyButtonUI()
    }
    @objc func setPeopleButtonActive(notification : Notification){
        setPeopleButtonUI()
    }
    
    func redirectToNearBy(){
        //print("redirect to near by called")
        //mainController.interrimLiveLocationView(poiID: globalConstant.POI)
        
        
            let vc = NearbyMapVC()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        hideDiscoverHUBView()
    }
    //MARK: - No people button clicks
    @IBAction func btnFindEventClicked(_ sender: UIButton) {
        
        
    }
    @IBAction func btnMyDiscoveryFilterClicked(_ sender: UIButton) {
        hideNoPeopleView()
        let objScopeVC = AppStoryboard.loadScopeVC()
        navigationController?.pushViewController(objScopeVC, animated: false)
        }
    @IBAction func btnRefreshClicked(_ sender: UIButton) {
        resetAndRefreshDataSource()
    }
    
    //MARK: - pause account setup
    func getPreferences() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        MainController().getScopeInfo(callback: { [self] (response) in
            // Toast is shown
            MBProgressHUD.hide(for: self.view, animated: true)
            if let Preferences : NSDictionary = response.value(forKey: "Preferences") as? NSDictionary {
                if let paused_to : String = Preferences.value(forKey: "paused_to") as? String {
                    let date : Date = paused_to.getDate("yyyy-MM-dd HH:mm:ss")
                    differenceInSeconds = Int(date.timeIntervalSince(Date()))
                    if differenceInSeconds > 0
                    {
                        UserDefaults.standard.setValue(true, forKey: WebKeyhandler.User.isPaused)
                        UserDefaults.standard.synchronize()
                        vwPause.isHidden = false
                        updateCounting()
                        self.activateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
                            self.updateCounting()
                        })
                    }
                    else{
                        setupPauseView()
                    }
                }
                else{
                    setupPauseView()
                }
            }
        })
    }
    
    @IBAction func btnResumeClicked(_ sender: UIButton) {
        activateAccount()
    }
    
    func activateAccount()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        MainController().pauseProfile(paused_for: "00:00:00", callback: { [self] (response) in
            MBProgressHUD.hide(for: self.view, animated: true)
            UserDefaults.standard.setValue(false, forKey: WebKeyhandler.User.isPaused)
            UserDefaults.standard.synchronize()
            setupPauseView()
        })
    }
    
    func setupPauseView(){
        vwPause.isHidden = true
        resetAndRefreshDataSource()
    }
    
    func updateCounting(){
        let (h, m, _) = differenceInSeconds.secondsToHoursMinutesSeconds()
        accountStatusBrif.text = "Select, “Resume” to discover people. You and your matches can still interact. Time until reactivation - \(h) hours \(m) minutes"
        differenceInSeconds -= 10
        if differenceInSeconds < 1
        {
            self.activateTimer?.invalidate()
            activateAccount()
        }
    }
    
    //MARK: - button clicks
    @IBAction func reloadMatchesBtn(_ sender: Any) {
        reloadCardsData()
    }

    @IBAction func forceMatch(_ sender: AnyObject) {
        // Test button
        // Crashlytics.sharedInstance().crash()

        // print(childViewControllers)
        // reloadDataSource(swipedCardAtIndex: 0)
    }

    //MARK:- Other Methods
    func reloadCardsData()
    {
        hideLastCardSwipeLogo()
        showKrownSearchLogo()
        //if allowSwipesRefresh == true {
            reloadDataSource(swipedCardAtIndex: 0)
            // Loading animation
//            startAnimatingKrownLogo()
            startAnimateKrownLogoForSearchPeople()
            allowSwipesRefresh = false
          //  reloadMatchesBtnOutlet.isHidden = true
            prepareAnimatedTextChange()
            lookingForKrowners.text = searchingString

            _ = Timer.scheduledTimer(withTimeInterval: 7, repeats: false, block: { (_) in
            if !isReloadingData {
                //self.reloadMatchesBtnOutlet.isHidden = false
                
                self.prepareAnimatedTextChange()
                self.lookingForKrowners.text = self.noneFoundString
            }
                self.allowSwipesRefresh = true
//                self.stopAnimationKrownLogo()
                self.stopAnimateKrownLogoForSearchPeople()
              //  self.reloadMatchesBtnOutlet.isHidden = false
                self.prepareAnimatedTextChange()
                self.lookingForKrowners.text = self.noneFoundString
        })
       // }
    }
    func prepareAnimatedTextChange() {
        let animation: CATransition = CATransition()
        animation.duration = 0.3
        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.lookingForKrowners.layer.add(animation, forKey: "changeTextTransition")
        self.reloadMatchesBtnOutlet.layer.add(animation, forKey: "changeTextTransition")
    }

    func startAnimatingKrownLogo() {

        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0.5
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        self.krownLogo.layer.add(pulseAnimation, forKey: "animateOpacity")
    }

    func stopAnimationKrownLogo() {
        if let presentation = krownLogo.layer.presentation() {
            if let currentOpacity = presentation.value(forKeyPath: #keyPath(CALayer.opacity)) as? CGFloat {
                krownLogo.layer.removeAllAnimations()
                let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
                pulseAnimation.duration = 1
                pulseAnimation.fromValue = currentOpacity
                pulseAnimation.toValue = 1
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                self.krownLogo.layer.add(pulseAnimation, forKey: "animateOpacity")
            }
        }
    }

    //MARK: - Notification trigger method
    @objc func resetAndRefreshDataSource(isReload : Bool = true )
    {
        hideNoPeopleView()
        hideLastCardSwipeLogo()
        dataSourceArr.removeAll()
        kolodaView.resetCurrentCardIndex() // Removes all cards from superView
        if isReload{
            reloadDataSource(swipedCardAtIndex: 0)
        }
        else{
            if self.allowSwipesRefresh {
                vwNoPerson.fadeOut()
                self.prepareAnimatedTextChange()
                self.lookingForKrowners.text = self.noneFoundString
                self.stopAnimateKrownLogoForSearchPeople()
            }
            else{
                vwNoPerson.fadeIn()
            }
        }
    }

    func resetSearchLogo()
    {
        krownCircleLogo.image = UIImage(named: "loading_animation_0")
        krownLogo.isHidden = false
    }
    //MARK: -
    func hideLastCardSwipeLogo()
    {
//        imgvwKrownLogoLastCard.isHidden = true
        showKrownSearchLogo()
    }
    func showLastCardSwipeLogo()
    {
//        imgvwKrownLogoLastCard.isHidden = false
        hideKrownSearchLogo()
    }
    func showKrownSearchLogo()
    {
        hideNoPeopleView()
        krownLogo.fadeIn()
        startAnimateKrownLogoForSearchPeople()
        
    }
    func hideKrownSearchLogo()
    {
        krownLogo.fadeOut()
    }
    func hideNoPeopleView()
    {
        vwNoPerson.fadeOut()
    }
    func showNoPeopleView()
    {
        vwNoPerson.fadeIn()
    }
}
//MARK:- Krown Logo loading for searching people
extension HomeVC
{
    func startAnimateKrownLogoForSearchPeople()
    {
        krownCircleLogo.animationImages = animatedImages(for: "loading_animation_")
        krownCircleLogo.animationDuration = 2.2
//        imgvwLoading.animationRepeatCount = 13
        krownCircleLogo.image = krownCircleLogo.animationImages?.first
        krownCircleLogo.startAnimating()
    }
    func animatedImages(for name: String) -> [UIImage] {
        
        var i = 0
        var images = [UIImage]()
        
        while let image = UIImage(named: "\(name)\(i)") {
            images.append(image)
            i += 1
            if(i==13)
            {
                break
            }
        }
        return images
    }
    func stopAnimateKrownLogoForSearchPeople()
    {
        krownCircleLogo.stopAnimating()
    }
    
}
extension HomeVC: KolodaViewDelegate {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        let view = Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
        return view
}
}
//MARK:- Cards Data methods
extension HomeVC: KolodaViewDataSource {
    
    public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return Int(dataSourceArr.count)
    }

    func koloda(_ koloda: KolodaView, viewForCardAt cardIndex: Int) -> UIView {
        // BUG: if swiping really fast while reloading the cardIndex becomes -1 and this creates an out of range fatal error
        var cardIndexx = 0
        if cardIndex == -1 {
         cardIndexx = 0
        } else {
            cardIndexx = cardIndex
        }
        /////////////////////////////////////////// Dirty solution///////////////////////////////////////////////////////
        let swipeDetailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swipeDetailView") as! SwipeDetailVC
      
        
        swipeDetailView.swipeInfo = dataSourceArr[Int(cardIndexx)]
        swipeDetailView.homeVC = self
        // SETUP OF THE VIEW//
        // This line below seems to create memory issues - This is needed for making the screen clickable.
        addChild(swipeDetailView)
        ///////////////////////////////////////////////

        swipeDetailView.view.layer.cornerRadius = 20
        swipeDetailView.createScrollView(viewSize: kolodaView.frameForCard(at: 0))
        return swipeDetailView.view
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
           // self.reloadMatchesBtnOutlet.isHidden = false
            prepareAnimatedTextChange()
            lookingForKrowners.text = noneFoundString
            isReloadingData = false // To make appear animation when no cards in stack
    }
    
    func koloda(_ thisKolodaView: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        // Answers.logCustomEvent(withName: "Swipe", customAttributes: [:])
        
        // remove cached images of the Person that is swiped away
        let imageURLArray = self.dataSourceArr[index].imageArray.compactMap { URL(string:$0) }
        
        CacheController.shared.removeSwipedPersonsCachedProfileImages(imageURLArray: imageURLArray)
        
        if self.dataSourceArr.count-index == 5 {
            //print("5 cards to go")
           reloadDataSource(swipedCardAtIndex: index)
        }

        if direction == SwipeResultDirection.right {
            likeUser(thisKolodaView: thisKolodaView, index: index)

        } else if direction == SwipeResultDirection.left {
            if globalConstant.isFlagSwipeAction == false{
                
                dislikeUser(thisKolodaView: thisKolodaView, index: index)
            }else{
                globalConstant.isFlagSwipeAction = false
            }
           
        }

        if dataSourceArr.count-1 == index
        {
            resetAndRefreshDataSource(isReload: false)
        }
        
        
        // removing the added childviewcontrollers if not removed it will cause the memory to leak
        children.first?.removeFromParent()

    }

    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        globalConstant.isSwipeWave = false
        //print("SwipeResultDirection - \(direction.rawValue)")
        //print("draggedCardWithPercentage - \(finishPercentage)")
        if (koloda.viewForCard(at: koloda.currentCardIndex)?.parentViewController?.isKind(of: SwipeDetailVC.self))! {
        }
        if dataSourceArr.count-1 == koloda.currentCardIndex
        {
            resetSearchLogo()
        }else{
            hideKrownSearchLogo()
        }
    }
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        // Do have appear animation on first run
        if isReloadingData == false {
            isReloadingData = true // then it is no longer the first run
            return true // to return first run

        }

        return !isReloadingData
    }

    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
       // Sets the transparency to zero while swiping the next cards
        return false
    }

    //MARK: - Action methods on users cards
    func likeUser(thisKolodaView: KolodaView, index: Int) {
        // like function
        let currentCardView = koloda(thisKolodaView, viewForCardAt: Int(index))
        let currentCardViewController = currentCardView.parentViewController as! SwipeDetailVC
        let swipeCardID = currentCardViewController.id

        // like in database
        let main = mainController
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String

        main.swipeAction(thisUserID, action: (globalConstant.isSwipeWave) ? 5 : 1, swipeCardID: swipeCardID) { (response) in
            if globalConstant.isSwipeWave{
                let wave : [String:Any] = response["Waves"] as? [String:Any] ?? [:]
                setWaveUsedUp(wave: wave)
            }

            if (response["ErrorCode"]! as! String) == "47" || (response["ErrorCode"]! as! String) == "InviteAction done"{
                if let _ : NSDictionary = response["match"] as? NSDictionary
                {
                    main.generateMatch(personDict: response, callback: { (match) in
                        self.showMatchVC(match: match)
                    })
                }
            }
        }
    }

    func displayLocationPopup() {
        let alertController = AlertController()
        alertController.displayLoginLocationAlertWithCompletion { success in
            //This will show if this is a success or not.
            if success {
                SwiftLocation.allowsBackgroundLocationUpdates = true
                SwiftLocation.pausesLocationUpdatesAutomatically = true
                // For refreshing the service once the location has been set. It fires on every load
                self.mainController.getLocation(2, forceGetLocation: true, withAccuracy: .city) { (locationDict) in
                        self.mainController.sendLocation(locationDict, callback: { (_) in
                            SwiftEntryKit.dismiss()
                            self.reloadDataSource(swipedCardAtIndex: 0)
                        })
                    }
            }
        }

    }

    func showMatchVC(match: MatchObject) {
        let matchVC = AppStoryboard.loadMatchVC()
        matchVC.match = match
        navigationController?.pushViewController(matchVC, animated: false)
    }

    func dislikeUser(thisKolodaView: KolodaView, index: Int) {
        // disslike function

        // disslike in database
        let currentCardView = koloda(thisKolodaView, viewForCardAt: Int(index))
        let currentCardViewController = currentCardView.parentViewController as! SwipeDetailVC
        let swipeCardID = currentCardViewController.id
        let main = mainController
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String

        main.swipeAction(thisUserID, action: 2, swipeCardID: swipeCardID) { (_) in
        }
    }
    
    func reloadDataSource(swipedCardAtIndex: Int) {
        Log.log(message: "Discover People DataSoure what reloaded based on call to server", type: .debug, category: Category.discover, content: "")

        reloadSwipeArray(callback: { [self]
            (swipeArray) in
            //print(swipeArray)
            if swipeArray.count == 0 {
                if self.allowSwipesRefresh {
                    vwNoPerson.fadeOut()
//                    vwNoPerson.fadeOut()
                  //  self.reloadMatchesBtnOutlet.isHidden = false
                    self.prepareAnimatedTextChange()
                    self.lookingForKrowners.text = self.noneFoundString
//                    self.stopAnimationKrownLogo()
                    self.stopAnimateKrownLogoForSearchPeople()
                }
                else{
//                    vwNoPerson.isHidden = false
                    vwNoPerson.fadeIn()
                }
            }
            else{
//                stopAnimationKrownLogo()
                self.stopAnimateKrownLogoForSearchPeople()
            }
          //  (UIApplication.shared.delegate as! AppDelegate).isFlagSwipeAction = false
            // 1 Check that the datasource does not have some of the PersonObjects that are in the datasource array

            //print("The count in the swipearray is \(swipeArray.count)")

            var personsInSwipeArray = swipeArray
            for personInDataSource in self.dataSourceArr {
                // 2 if the person exists in the in the dataSource then remove it from the personsInSwipeArray
                if let i = personsInSwipeArray.firstIndex(where: { $0.id == personInDataSource.id }) {
                    // print("Removed a person at index \(i) which and the id's were the same \(personsInSwipeArray[i].id == personInDataSource.id)")
                    personsInSwipeArray.remove(at: i)
                }

            }

            // 3 remove the contents that has been swiped in the datasource to avoid using too much memory
//            print("The dataSource Count \(self.dataSourceArr.count)")
            //print("The amount of swipes that has been swiped already \(swipedCardAtIndex)")

            for _ in (0..<swipedCardAtIndex+1)// +1 to always remove the last swiped person
            {
                if self.dataSourceArr.count > 0 { // is empty on the first run so cant remove first
                self.dataSourceArr.removeFirst()
                }
            }
            //print("After clean the dataSource Count \(self.dataSourceArr.count)")

            // 4 append the refreshed persons downloaded
            self.dataSourceArr.append(contentsOf: personsInSwipeArray)

            // 5 Refresh the view to contain the last appended elements
            DispatchQueue.main.async {
                    self.kolodaView.resetCurrentCardIndex()
                }
            if self.dataSourceArr.count >= 1 {
              //  self.reloadMatchesBtnOutlet.isHidden = true
               // self.vwNoPerson.isHidden = true
                self.prepareAnimatedTextChange()
                self.lookingForKrowners.text = self.searchingString
            }

            // to clear the three childViewControllers that get stuck in reloading the swiping cards
            for _ in self.children {
                if swipedCardAtIndex != 0 {
                    self.children.first?.removeFromParent()
                    Log.log(message: "Removed extra childViewController on reload of data", type: .debug, category: Category.discover, content: "")
                }
                // print(self.childViewControllers)

            }
            
            //To show screen for no people contet
            if(self.dataSourceArr.count == 0)
            {
//                vwNoPerson.isHidden = false
                vwNoPerson.fadeIn()
            }else{
//                vwNoPerson.isHidden = true
                vwNoPerson.fadeOut()
            }
        })

    }

   
    func reloadSwipeArray(callback : @escaping ([PersonObject]) -> Void) {

        mainController.distributeSwipeArray((UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String), callback: callback)
        
    }

}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct HomeVCPreview: PreviewProvider {
    
    static var previews: some View {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeVC").toPreview()
    }
}
#endif

