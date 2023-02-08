//
//  ProfilePreviewVC.swift
//  Krown
//
//  Created by Mac Mini 2020 on 08/04/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI
import Koloda
import SDWebImage

class ProfilePreviewVC: UIViewController {
    
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var btnEdit: UIButton!
    var profileInfo: PersonObject!
    var mainController: MainController = MainController()
    // var isBackFromEdit = Bool()
    private var isReloadingData = false
    var kolodaViewNumberOfCards = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // isBackFromEdit = false
        globalConstant.isDissmiss = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        self.tabBarController?.tabBar.layer.zPosition = -1
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if globalConstant.isDissmiss == true {
//            self.navigationController?.popViewController(animated: true)
        }else{
            setUserInfo()
            btnEdit.layer.cornerRadius = 25
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //tabBarController!.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844);
    }
    override func viewDidAppear(_ animated: Bool) {
        self.kolodaViewNumberOfCards = 1
        self.kolodaView.resetCurrentCardIndex()
    }
    func setupKolodaView() {
        self.view.addSubview(kolodaView)
        self.view.bringSubviewToFront(kolodaView)
    }
    
    @IBAction func bckAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnEdit(_ sender: Any) {
        let swiftUIView = ProfileView()
        globalConstant.isDissmiss = true
        let homeViewController = UIHostingController(rootView: swiftUIView)
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
}
extension ProfilePreviewVC: KolodaViewDelegate {}
extension ProfilePreviewVC: KolodaViewDataSource {
    
    public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return kolodaViewNumberOfCards
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt cardIndex: Int) -> UIView {
        // BUG: if swiping really fast while reloading the cardIndex becomes -1 and this creates an out of range fatal error
        
        /////////////////////////////////////////// Dirty solution///////////////////////////////////////////////////////
        let swipeDetailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swipeDetailView") as! SwipeDetailVC
        swipeDetailView.swipeInfo = profileInfo
        addChild(swipeDetailView)
        globalConstant.isPreviewScreen = true
        swipeDetailView.view.layer.cornerRadius = 20
        swipeDetailView.dislikeButton.isHidden = true
        swipeDetailView.likeButton.isHidden = true
        swipeDetailView.waveButton.isHidden = true
        swipeDetailView.viewDialogWave.isHidden = true
        swipeDetailView.isFromHome = false
        swipeDetailView.createScrollView(viewSize: kolodaView.frameForCard(at: 0))
        
        addChild(swipeDetailView)
        ///////////////////////////////////////////////
        
        
        return swipeDetailView.view
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.isHidden = true
        
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        self.navigationController?.popViewController(animated: true)
        // Spins the arrow in the menu
        
    }
    
    func setUserInfo() {
        let main = MainController()
        let ownUserID = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        main.distributeMatch(ownUserID) { (profile) in
            
            self.profileInfo = profile
            self.kolodaView.dataSource = self
            self.kolodaView.delegate = self
            self.setupKolodaView()
        }
    }
    
}

