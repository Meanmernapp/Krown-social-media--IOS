//
//  SwipeDetailVC.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import Koloda
import Alamofire
import MBProgressHUD
import AVFoundation
import CoreLocation
import SDWebImage

class SwipeDetailVC: UIViewController, UIScrollViewDelegate {
    
    var buttonAction: ((UIButton) -> Void)?
    var buttonLeftAction: ((UIButton) -> Void)?
    var buttonRightAction: ((UIButton) -> Void)?

    var imageURLArray: [URL] = []
    var eventList: [EventObject] = []
    var id = ""
    var statusString = ""
    var position = ""
    var employer = ""
    var cTime : Float = Float()
    var swipeInfo: PersonObject!
    var looper: [AVPlayerLooper] = []
    var selectedIdx : Int = Int()
    var homeVC : HomeVC = HomeVC()
    var isFromHome = true
    @IBOutlet weak var eventTopBar: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var commonFriendsCount: UILabel!
    @IBOutlet weak var nameAndAge: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var eventContainerView: UIView!
    @IBOutlet weak var viewCalendar: UIView!
    @IBOutlet weak var viewDistance: UIView!
    @IBOutlet weak var pageCollView: UICollectionView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var waveButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!

    @IBOutlet weak var lbl_distance: UILabel!
    @IBOutlet weak var viewDialogWave: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var vwInfo2: UIView!
    @IBOutlet weak var blurview2: UIVisualEffectView!
    @IBOutlet weak var commonFriendsCount2: UILabel!
    @IBOutlet weak var nameAndAge2: UILabel!
    @IBOutlet weak var viewCalendar2: UIView!
    @IBOutlet weak var eventTopBar2: UILabel!
    @IBOutlet weak var viewDistance2: UIView!
    @IBOutlet weak var lbl_distance2: UILabel!
    @IBOutlet weak var lblInterests: UILabel!
    @IBOutlet weak var cvInterests: UICollectionView!
    
    @IBAction func swipeLeftPressedDown(_ sender: UIButton) {}
    @IBAction func swipeLeftPressCanceled(_ sender: Any) {}
    @IBAction func swipeRightPressedDown(_ sender: UIButton) {}
    @IBAction func swipeRightPressedCanceled(_ sender: Any) {}
    
    var visibleImageView: UIImageView = UIImageView()
    var isViewActive : Bool = Bool()
    

    @IBAction func swipeLeft(_ sender: Any) {
        
        if isFromHome{
            if self.parent != nil {
           let homeVC = (self.parent as! HomeVC)
           homeVC.swipeRight()

           }
        }
        else{
            self.buttonRightAction?(sender as! UIButton)
        }
        
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        
        if isFromHome{
            if self.parent != nil {
                let homeVC = (self.parent as! HomeVC)
                homeVC.swipeLeft()
            }
        }
        else{
            self.buttonLeftAction?(sender as! UIButton)
        }
    }
    @IBAction func waveClick(_ sender: UIButton) {
        self.buttonAction?(sender)
        if isFromHome{
            if let isClickWave : Bool = UserDefaults.standard.value(forKey: UserDefaultsKeyHandler.Login.hasClickWaveBefore) as? Bool {
                if !isClickWave {
                    viewDialogWave.isHidden = false
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeyHandler.Login.hasClickWaveBefore)
                } else {
                    if self.parent != nil {
                   let homeVC = (self.parent as! HomeVC)
                   homeVC.swipeWaveRight()
    
                   }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isViewActive = true
        pageCollView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        if let countOfDiscoverPeopleAccesses : Int = UserDefaults.standard.value(forKey: UserDefaultsKeyHandler.Login.countOfDiscoverPeopleAccesses) as? Int {
            if countOfDiscoverPeopleAccesses == 3 {
                if let isClickWave : Bool = UserDefaults.standard.value(forKey: UserDefaultsKeyHandler.Login.hasClickWaveBefore) as? Bool {
                    if !isClickWave {
                        viewDialogWave.isHidden = false
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeyHandler.Login.hasClickWaveBefore)
                    }
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        globalConstant.isPreviewScreen = false
    }
    @objc func dismissView() {
        viewDialogWave.isHidden = true
    }

    override func viewDidLoad() {
        viewDialogWave.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
        pageCollView.dataSource = self
        pageCollView.delegate = self
        pageCollView.register(UINib(nibName: "PageControllCollCell", bundle: nil), forCellWithReuseIdentifier: "PageControllCollCell")
        registercell()
        // Customize layout
        // Todo: Fix bug not allowing this instead of line below // as seen in https://stackoverflow.com/questions/39595047/uivisualeffectview-with-mask-layer
        [infoView,vwInfo2].forEach{ view in
            view?.layer.cornerRadius = 20
            view?.clipsToBounds = true
        }
        if(swipeInfo.interests.count >= 1){
            vwInfo2.isHidden = false
            lblInterests.isHidden = false
        }
        else{
            vwInfo2.isHidden = true
            lblInterests.isHidden = true
        }
        
        scrollView.layer.cornerRadius = 20

        [nameAndAge,nameAndAge2].forEach{ label in
            label?.text = swipeInfo.name + " - " + swipeInfo.age
            label?.textColor = UIColor.offWhite
        }
        

        self.id = swipeInfo.id
        self.statusString = swipeInfo.status
        self.position = swipeInfo.position
        self.employer = swipeInfo.employment

        // This here display a common event if it exists
        if swipeInfo.events.count > 0 {

            [eventTopBar,eventTopBar2].forEach{ label in
                    label?.text =  String("Attending \(swipeInfo.events[0].title)")
                    label?.textColor = UIColor.offWhite
            }
            [viewCalendar,viewCalendar2].forEach{ view in
                view?.isHidden = false
            }
            self.eventList =  swipeInfo.events
        } else {
            [viewCalendar,viewCalendar2].forEach{ view in
                view?.isHidden = true
            }
            // If no events present hide the layer
        }
        if swipeInfo.distance.count > 0 {
            [viewDistance,viewDistance2].forEach{ view in
                view?.isHidden = false
            }
            if swipeInfo.distance == "0" {
                [lbl_distance,lbl_distance2].forEach{ label in
                    label?.text = "< 1 km away"
                }
            } else {
                [lbl_distance,lbl_distance2].forEach{ label in
                    label?.text = "\(swipeInfo.distance) km away"
                }
            }
        } else {
            [viewDistance,viewDistance2].forEach{ view in
                view?.isHidden = true
            }
        }

        // This adds the pictures to the array
        pageCollView.isHidden = swipeInfo.imageArray.count == 1 ? true : false
        for index in 0..<swipeInfo.imageArray.count {
            let url  = URL(string: swipeInfo.imageArray[index])!
            self.imageURLArray.append(url)
        }

        // Without this part below the eventTopBar stays event though it is removed
        self.didMove(toParent: self)
        self.view.translatesAutoresizingMaskIntoConstraints = false

        // TODO: consider moving this to personobject creation
        [commonFriendsCount,commonFriendsCount2].forEach{ label in
            label?.textColor = UIColor.offWhite
        }
        // To make animation stay inside the card
        self.view.clipsToBounds = true
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.scrollView.addGestureRecognizer(lpgr)

        super.viewDidLoad()
    }
    func refreshData()
    {
        isViewActive = true
        pageCollView.reloadData()
    }
    

    //MARK: - UILongPressGestureRecognizer Action -
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            //print("When lognpress is start or running")
            isViewActive = false
            pageCollView.reloadData()
        }
        else {
            //print("When lognpress is finish")
            isViewActive = true
            pageCollView.reloadData()
        }
    }
    
    //MARK: - interests collectionview code
    func registercell(){
        cvInterests.delegate = self
        cvInterests.dataSource = self
        self.cvInterests.register(UINib.init(nibName: "InterestCollCell", bundle: nil), forCellWithReuseIdentifier: "cell")
     
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cvInterests.frame.size.width/3, height: cvInterests.frame.size.height/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        cvInterests!.collectionViewLayout = layout
        
        cvInterests.isScrollEnabled = false
        
        cvInterests.reloadData()
    }

    @IBAction func showProfileDetails(_ sender: UIButton) {
            //print("Show profile button clicked")
            isViewActive = false
            pageCollView.reloadData()

            // Setup VC
            let vc = storyboard?.instantiateViewController(withIdentifier: "profileDetails") as! SwipeProfileVC
            //print(self.swipeInfo.interests.count)
            vc.swipeInfo = self.swipeInfo
            vc.selectedIdx = selectedIdx
            vc.homeVC = homeVC
            vc.isFromHome = isFromHome
            vc.isShowInterst = sender.tag == 1 ? false : true
            self.profileContainerView.addSubview(vc.view!)
            vc.view.tag = 100
            // Animate the view when it enters
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                vc.view.frame = CGRect(x: vc.view.frame.minX, y: vc.view.frame.minY-vc.view.frame.height, width: vc.view.frame.width, height: vc.view.frame.height)
            })
            // Info: ChildviewController is removed in SwipeProfileVC
            self.addChild(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: self.profileContainerView.frame.size.width, height: self.profileContainerView.frame.size.height)
            vc.didMove(toParent: self)

            // Hide and show different layers
            profileContainerView.isHidden = false
            infoView.isHidden = true
            vwInfo2.isHidden = true
            self.view.bringSubviewToFront(profileContainerView)
    }
    @IBAction func showEventDetails(_ sender: UIButton) {
      
            //print("Show eventdetails button clicked")
            isViewActive = false
            pageCollView.reloadData()

            // Setup VC
            let vc = storyboard?.instantiateViewController(withIdentifier: "eventDetailList") as! SwipeEventListVC
            vc.swipeInfo = self.swipeInfo
            vc.isShowInterst = sender.tag == 0 ? false : true
            self.eventContainerView.addSubview(vc.view!)

            // Animate the view when it enters
            vc.view.tag = 200

            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                vc.view.frame = CGRect(x: vc.view.frame.minX, y: vc.view.frame.maxY, width: vc.view.frame.width, height: vc.view.frame.height)
            })

            // Info: ChildviewController is removed in SwipeProfileVC
            self.addChild(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: self.eventContainerView.frame.size.width, height: self.eventContainerView.frame.size.height)
            vc.didMove(toParent: self)

            // Hide and show different layers
            eventContainerView.isHidden = false
            infoView.isHidden = true
            vwInfo2.isHidden = true
            self.view.bringSubviewToFront(eventContainerView)



    }

    func createScrollView(viewSize: CGRect) {
        var yPosition: CGFloat = 0
        var scrollViewContentSize: CGFloat = 0
        for index in 0..<imageURLArray.count {

            var imageUrl = imageURLArray[index]
            let imageView: UIImageView = UIImageView()

            // For handling Gifs and other picture types
            if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                
                // DiscoverPeopleVideoPlayer supports cache
                let queuePlayer = DiscoverPeopleVideoPlayer.shared.play(with: imageUrl)
                let playerLayer = AVPlayerLayer(player: queuePlayer)
                
                playerLayer.frame = view.layer.bounds
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.player = queuePlayer

                imageView.layer.addSublayer(playerLayer)
                queuePlayer.play()

            } else {
                let lastPartComponent = WebKeyhandler.imageHandling.mediumProfileImage + imageUrl.lastPathComponent
                imageUrl.deleteLastPathComponent()
                imageUrl.appendPathComponent(lastPartComponent)
                
                //Why are we canceling?
                imageView.sd_cancelCurrentImageLoad()
                if let image = SDImageCache.shared.imageFromDiskCache(forKey: imageUrl.absoluteString) {
                    imageView.image = image
                } else {
                    guard let thumbnailImage = UIImage(named: "man.jpg") else {
                        imageView.image = nil
                        return
                    }
                    
                    imageView.sd_imageIndicator?.startAnimatingIndicator()
                    //When setting image here it looks like we are downloading and then looking in cache and setting it after download which make little sense
                    imageView.sd_setImage(with: imageUrl, placeholderImage: thumbnailImage) { (image, err, type, url) in
                        
                        if let image = SDImageCache.shared.imageFromDiskCache(forKey: imageUrl.absoluteString) {
                            imageView.image = image
                        } else {
                            imageView.image = thumbnailImage
                        }
                        
                        imageView.sd_imageIndicator?.stopAnimatingIndicator()
                    }
                }
            }

            imageView.frame = viewSize
            imageView.frame.origin.y = yPosition
            imageView.contentMode = UIView.ContentMode.scaleAspectFill

            scrollView.addSubview(imageView)
            yPosition += imageView.frame.size.height
            scrollViewContentSize += imageView.frame.size.height
            scrollView.contentSize = CGSize(width: imageView.frame.width, height: scrollViewContentSize)
        }
        if imageURLArray.count > 0 {
            if let imgView : UIImageView = scrollView.subviews[0] as? UIImageView {
                visibleImageView = imgView
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.y/scrollView.frame.height)
        // If a user does not have any pictures and you try to scroll on the screen this will break somewhere here.
        if (scrollView.subviews.count >= 1){
            if let imgView : UIImageView = scrollView.subviews[selectedIdx] as? UIImageView {
                visibleImageView = imgView
            }
        }
        selectedIdx = Int(pageIndex)
        pageCollView.reloadData()
    }
}

extension SwipeDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, pageNextDelegate {
    func getCurrentTime(_ time: Float) {
        cTime = time
    }
    
    func gotoNextPage() {
        cTime = 0
        if selectedIdx == (swipeInfo.imageArray.count - 1) {
            selectedIdx = 0
        } else {
            selectedIdx += 1
        }
        if let imgView : UIImageView = scrollView.subviews[selectedIdx] as? UIImageView {
            visibleImageView = imgView
        }
        scrollView.scrollRectToVisible(visibleImageView.frame, animated: true)
        pageCollView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvInterests{
            let count = swipeInfo.interests.count
            return  count >= 6 ? 6 : count
        }
        else{
            return swipeInfo.imageArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvInterests
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InterestCollCell
            let interestResponse = swipeInfo.interests[indexPath.row]
            cell.lblName.text = interestResponse.interest
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
            cell.lblName.clipsToBounds = true
            cell.lblName.layer.cornerRadius = 10
            cell.lblName.adjustsFontSizeToFitWidth = true
            cell.lblName.textColor =  interestResponse.common  == "0" ?  UIColor.royalPurple :  UIColor.white
            cell.lblName.backgroundColor =  interestResponse.common  == "0" ?  UIColor.darkWinterSky :  UIColor.royalPurple
            
            return cell
        }
        else{
            var cell = UICollectionViewCell()
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageControllCollCell", for: indexPath)
            if let view = cell as? PageControllCollCell {
                if selectedIdx == indexPath.item && swipeInfo.imageArray.count > 1 && isViewActive {
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

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvInterests
        {
            return CGSize(width: cvInterests.frame.size.width/3, height: cvInterests.frame.size.height/2)
        }
        else{
            return CGSize(width: 10, height: 10)
        }
        
    }
    
}
