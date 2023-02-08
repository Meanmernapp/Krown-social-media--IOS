//
//  SwipeCardPreview.swift
//  Krown
//
//  Created by macOS on 12/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import Koloda
import Photos

class SwipeCardPreview: UIViewController {

    var kolodaView = KolodaView()
    var kolodaViewNumberOfCards = 0
    var personObject = PersonObject()

    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        setupKolodaView()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        let width : CGFloat = self.view.frame.width - 32
        kolodaView.frame = CGRect(x: 16, y: 100, width: width, height: self.view.frame.height - 180)
        self.kolodaViewNumberOfCards = 1
        self.kolodaView.resetCurrentCardIndex()
    }

    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func setupKolodaView() {
        self.view.addSubview(kolodaView)
        self.view.bringSubviewToFront(kolodaView)
    }


}
extension SwipeCardPreview: KolodaViewDelegate {}
extension SwipeCardPreview: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let swipeDetailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swipeDetailView") as! SwipeDetailVC
        swipeDetailView.swipeInfo = self.personObject
        addChild(swipeDetailView)
        swipeDetailView.view.layer.cornerRadius = 20
        swipeDetailView.dislikeButton.isHidden = true
        swipeDetailView.likeButton.isHidden = true
        swipeDetailView.waveButton.isHidden = true
        swipeDetailView.createScrollView(viewSize: kolodaView.frameForCard(at: 0))
        
        addChild(swipeDetailView)
        
        return swipeDetailView.view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return kolodaViewNumberOfCards
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // Hides the view so it is possible to click again on the UI Below
        kolodaView.isHidden = true
        // messageInputBar.isHidden = false
        
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        self.navigationController?.popViewController(animated: true)
        // Spins the arrow in the menu
        
    }
    
    // needed for getting permission to Photos
    func getPermissionIfNecessary(completionHandler: @escaping (Bool) -> Void) {
        
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completionHandler(true)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            completionHandler(status == .authorized ? true : false)
        }
    }
    
}
