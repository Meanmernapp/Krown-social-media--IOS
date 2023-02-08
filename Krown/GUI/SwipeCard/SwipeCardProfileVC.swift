//
//  SwipeProfileVC.swift
//  Krown
//
//  Created by KrownUnity on 26/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import AlamofireImage
import MessageUI
import CoreLocation
import SwiftUI

class SwipeProfileVC: UIViewController {
    @IBOutlet weak var view_interests: UIView!
    @IBOutlet weak var view_space_education: UIView!
    @IBOutlet weak var view_space_work: UIView!

    var mainController = MainController()
    var nameAndAgeString = ""
    var commenFriendsString = ""
    var commenInterestsString  = ""
    var positionAndEmployerString = ""
    var statusString = ""
    var educationAndSchoolString = ""
    var swipeInfo: PersonObject!
    var selectedIdx : Int = Int()
    var homeVC : HomeVC = HomeVC()
    var profilePreviewVC : ProfilePreviewVC = ProfilePreviewVC()
    var message = String() //flag message
    var isShowInterst : Bool = false
    var isFromHome = true
    
    @IBOutlet weak var view_bio: UIView!
    
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var profileDetailsView: UIView!
    @IBOutlet weak var MeetSigneCollView: UICollectionView!
    @IBOutlet weak var PastEventsCollView: UICollectionView!
    @IBOutlet weak var viewMeetSigne: UIView!
    @IBOutlet weak var viewPastEvents: UIView!
    @IBOutlet weak var lbl_meet: UILabel!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var btnFlag: UIButton!
    @IBOutlet weak var view_calander: UIView!
    @IBOutlet weak var view_distance: UIView!
    @IBOutlet weak var view_work: UIView!
    @IBOutlet weak var view_education: UIView!
    
    
    @IBOutlet weak var view_space_interests: UIView!
    @IBOutlet weak var InterestCollHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_event_title: UILabel!
    @IBOutlet weak var lbl_calander: UILabel!
    @IBOutlet weak var lbl_distance: UILabel!
    @IBOutlet weak var lbl_work: UILabel!
    @IBOutlet weak var lbl_bio: UILabel!
    @IBOutlet weak var lbl_education: UILabel!
    @IBOutlet weak var interestCollection: UICollectionView!
    @IBOutlet weak var imgProfile: UIImageView! {
        didSet {
            imgProfile.layer.cornerRadius = 32.5
        }
    }
    @IBOutlet weak var bottomPathView: UIView! {
        didSet {
            bottomPathView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var bottomPathViewBg: UIView! {
        didSet {
            bottomPathViewBg.layer.cornerRadius = 20
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 20
        MeetSigneCollView.dataSource = self
        MeetSigneCollView.delegate = self
        MeetSigneCollView.register(UINib(nibName: "EventCollCell", bundle: nil), forCellWithReuseIdentifier: "EventCollCell")
        PastEventsCollView.dataSource = self
        PastEventsCollView.delegate = self
        PastEventsCollView.register(UINib(nibName: "EventCollCell", bundle: nil), forCellWithReuseIdentifier: "EventCollCell")
        interestCollection.dataSource = self
        interestCollection.delegate = self
        self.interestCollection.register(UINib.init(nibName: "InterestCollCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        initialSetup()
    }

    func initialSetup()
    {
        viewLocation.isHidden = true

        if swipeInfo.distance.count > 0 {
            if swipeInfo.distance == "0" {
                lbl_distance.text = "< 1 km away"
            } else {
                lbl_distance.text = "\(swipeInfo.distance) km away"
            }
        }
        
        viewMeetSigne.isHidden = (swipeInfo.events.count > 0) ? false : true
        viewPastEvents.isHidden = (swipeInfo.events.count > 0) ? true : true
        lbl_event_title.text = swipeInfo.name
        lbl_meet.text = "Meet \(swipeInfo.name) at"
        view_calander.isHidden = !(swipeInfo.events.count > 0)
        view_distance.isHidden = !(swipeInfo.distance.count > 0)
        view_work.isHidden = !(swipeInfo.employment.count > 0 || swipeInfo.position.count > 0)
        view_space_work.isHidden = !(swipeInfo.employment.count > 0 && swipeInfo.position.count > 0)
        view_education.isHidden = !(swipeInfo.education.count > 0)
        view_space_education.isHidden = !(swipeInfo.education.count > 0)
        view_bio.isHidden = !(swipeInfo.status.count > 0)
        interestCollection.isHidden = !(swipeInfo.interests.count > 0)
        view_interests.isHidden = !(swipeInfo.interests.count > 0)
        view_space_interests.isHidden = !(swipeInfo.interests.count > 0)
        if swipeInfo.events.count > 0 {
            lbl_calander.text = String("Attending \(swipeInfo.events[0].title)")//swipeInfo.concentration
        }
        
        if swipeInfo.position != "" && swipeInfo.employment != "" {
            self.lbl_work.text = swipeInfo.position + " - " + swipeInfo.employment
        } else if swipeInfo.position == "" && swipeInfo.employment != "" {
            self.lbl_work.text = swipeInfo.employment
        } else if swipeInfo.position != "" && swipeInfo.employment == "" {
            self.lbl_work.text = swipeInfo.position
        } else {
            self.lbl_work.text = ""
        }
        
        
        //  lbl_work.text = swipeInfo.employment
        lbl_education.text = swipeInfo.education
        lbl_bio.text = swipeInfo.status
        if swipeInfo.imageArray.count > selectedIdx {
            imgProfile.sd_setImage(with: URL(string: swipeInfo.imageArray[selectedIdx]), placeholderImage: UIImage(named: "placeholder"), options: .retryFailed, context: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //print(#function)
       // self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = interestCollection.collectionViewLayout.collectionViewContentSize.height
        InterestCollHeight.constant = height
        self.view.layoutIfNeeded()
    }
    override func viewDidAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func btnFlag(_ sender: Any) {
        tabBarController?.tabBar.alpha = isFromHome ? 1 : 0
        let alertController = UIAlertController()
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.white
        
        let fakeProfileBtn = UIAlertAction(title: "Fake profile", style: .default, handler: { (_) -> Void in
            //print("Fake Profile button tapped")
            
            self.message = "Fake profile"
           // self.flagUserProfileEmail(message: message)
            self.BlockActionAPI()
        })
        fakeProfileBtn.setValue(UIColor.slateGrey, forKey: "titleTextColor")
        let  hateSpeachBtn = UIAlertAction(title: "Hate speach", style: .default, handler: { (_) -> Void in
            //print("Hate speach button tapped")
            self.message = "Hate speech"
           // self.flagUserProfileEmail(message: message)
            self.BlockActionAPI()
        })
        
        hateSpeachBtn.setValue(UIColor.slateGrey, forKey: "titleTextColor")
        let  inappropriateContentBtn = UIAlertAction(title: "Inappropriate content", style: .default, handler: { (_) -> Void in
            //print("Hate speach button tapped")
            self.message = "Inappropriate content"
            //self.flagUserProfileEmail(message: message)
            self.BlockActionAPI()
        })
        
        inappropriateContentBtn.setValue(UIColor.slateGrey, forKey: "titleTextColor")
        let scamAdvertisingBtn = UIAlertAction(title: "Scam/advertising", style: .default, handler: { (_) -> Void in
            //print("Scam/advertising button tapped")
            self.message = "Scam/advertising"
           // self.flagUserProfileEmail(message: message)
            self.BlockActionAPI()
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
            //print("Cancel button tapped")
        })
        cancelButton.setValue(UIColor.slateGrey, forKey: "titleTextColor")
        scamAdvertisingBtn.setValue(UIColor.slateGrey, forKey: "titleTextColor")
        alertController.addAction(fakeProfileBtn)
        alertController.addAction(hateSpeachBtn)
        alertController.addAction(inappropriateContentBtn)
        alertController.addAction(scamAdvertisingBtn)
        alertController.addAction(cancelButton)
        // self.navigationController!.present(alertController, animated: true, completion: nil)
        alertController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad
        
        present(alertController, animated: true) {
            //print("option menu presented")
        }

    }
  
    @IBAction func returnBtn(_ sender: AnyObject) {
        removeSubview()
    }
   
    @IBAction func reportBtn(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Flag In-appropirate Behavior", message: "Block User and Flag In-appropriate Behavior", preferredStyle: .actionSheet)
        
        let offenceBtn = UIAlertAction(title: "Offensive Content", style: .destructive, handler: { (_) -> Void in
            //print("Offence button tapped")
            let message = "User \(String(describing: UserDefaults.standard.string(forKey: WebKeyhandler.User.userID)!) ) has flagged user \(self.swipeInfo.id) for having an offensive post"
            self.flagUserEmail(message: message)
        })
        
        let targetBtn = UIAlertAction(title: "Post Targets Someone", style: .destructive, handler: { (_) -> Void in
            //print("Targets someone button tapped")
            let message = "User \(String(describing: UserDefaults.standard.string(forKey: WebKeyhandler.User.userID)!) ) has flagged user \(self.swipeInfo.id) for having a targeting post"
            self.flagUserEmail(message: message)
        })
        
        let  otherBtn = UIAlertAction(title: "Other", style: .destructive, handler: { (_) -> Void in
            //print("Other button tapped")
            let message = "User \(String(describing: UserDefaults.standard.string(forKey: WebKeyhandler.User.userID)!)) has flagged user \(self.swipeInfo.id) for an offensive post relating to other post"
            self.flagUserEmail(message: message)
            
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
            //print("Cancel button tapped")
        })
        
        alertController.addAction(offenceBtn)
        alertController.addAction(targetBtn)
        alertController.addAction(otherBtn)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        
    }
    func BlockActionAPI() {
        // Block in database
        let main = mainController
        let thisUserID: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        let swipeCardID : String = swipeInfo.id
        main.swipeAction(thisUserID, action: 4, swipeCardID: swipeCardID) { (response) in
            
            if (response["ErrorCode"]! as! String) == "47" || (response["ErrorCode"]! as! String) == "InviteAction done"{
               
                self.flagUserProfileEmail(message: self.message)
            }
        }
    }

    func flagUserEmail(message: String) {
    let mainController = mainController
        mainController.sendEmail(to: swipeInfo.id, message: message) { (_) in

        }
    }

    func flagUserProfileEmail(message: String) {
        let mainController = mainController
        mainController.sendUserProfileEmail(to: swipeInfo.id, message: message, report_type: "User Profile Reporting") { (_) in
            if self.parent != nil {
                globalConstant.isFlagSwipeAction = true
                let homeVC = (self.parent as! SwipeDetailVC)
                homeVC.swipeRight((Any).self)
                
            }
        }
    }
    
    // MARK: Delegate for collectionView

    func removeSubview() {
        //print("Start remove subview")
        if let viewWithTag = self.view.viewWithTag(100) {
            UIView.animate(withDuration: 0.2, animations: {
                viewWithTag.frame = CGRect(x: viewWithTag.frame.maxX-viewWithTag.frame.width, y: viewWithTag.frame.maxY, width: viewWithTag.frame.width, height: viewWithTag.frame.height)
            }, completion: { _ in
                viewWithTag.removeFromSuperview()
                            let swipeDetailVC = self.parent as! SwipeDetailVC
                            swipeDetailVC.refreshData()
                            swipeDetailVC.view.sendSubviewToBack(swipeDetailVC.profileContainerView)
                            let containerView = swipeDetailVC.profileContainerView
                            let infoView = swipeDetailVC.infoView
                            let infoView2 = swipeDetailVC.vwInfo2

                            containerView?.isHidden = true
//                            infoView?.isHidden = false
                if self.isShowInterst{
                    infoView?.isHidden = true
                    infoView2?.isHidden = false
                }
                else{
                    infoView?.isHidden = false
                    infoView2?.isHidden = true
                }


            })

        } else {
            //print("No!")
        }
    }

}
extension SwipeProfileVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == MeetSigneCollView {
            return swipeInfo.events.count
        }else if collectionView == interestCollection{
            return swipeInfo.interests.count
        }else {
            return 1
        }
        
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == MeetSigneCollView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollCell", for: indexPath)
            let event : EventObject = swipeInfo.events[indexPath.item]
            if let view : EventCollCell = cell as? EventCollCell {
                view.lbl_event_title.text = event.title
                view.imgEvent.sd_setImage(with: URL(string: event.imageURL), placeholderImage: UIImage(named: "placeholder"), options: .retryFailed, context: nil)
                view.lbl_date.text = event.timeStart.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").dateString(withFormat: "dd")
                view.lbl_month.text = event.timeStart.getDate("yyyy-MM-dd'T'HH:mm:ssZZZZ").dateString(withFormat: "MMM")
                if swipeInfo.distance.count > 0 {
                    if swipeInfo.distance == "0" {
                        view.lbl_location.text = "< 1 km away"
                    } else {
                        view.lbl_location.text = "\(swipeInfo.distance) km away"
                    }
                } else {
                    view.lbl_location.text = "< 1 km away"
                }
                if globalConstant.isPreviewScreen ==  true {
                    view.btn_event.isUserInteractionEnabled = false
                }else{
                    view.btn_event.isUserInteractionEnabled = true
                }
                view.btn_event.tag = indexPath.item
                view.btn_event.addTarget(self, action: #selector(btn_event(_:)), for: .touchUpInside)
            }
            return cell
        }else if collectionView == interestCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InterestCollCell
            cell.lblName.text = swipeInfo.interests[indexPath.row].interest
           
            cell.lblName.clipsToBounds = true
            cell.lblName.textAlignment = .center
            cell.lblName.layer.cornerRadius = cell.lblName.frame.size.height / 2
            cell.lblName.layer.borderWidth = 1
            cell.lblName.layer.borderColor =  UIColor.royalPurple.cgColor
            cell.lblName.textColor =  swipeInfo.interests[indexPath.row].common  == "0" ?  UIColor.royalPurple :  UIColor.white
            cell.lblName.backgroundColor =  swipeInfo.interests[indexPath.row].common  == "0" ?  UIColor.darkWinterSky :  UIColor.royalPurple
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollCell", for: indexPath)
            return cell
        }
        // return cell
    }
    @objc func btn_event(_ sender: UIButton) {
        let event : EventObject = swipeInfo.events[sender.tag]
        var dict : [String : Any] = [String : Any]()
        dict["created_at"] = event.timeStart
        dict["event_title"] = event.title
        dict["matchCount"] = event.totalAttending
        dict["cover_url"] = event.imageURL
        dict["description"] = event.description
        dict["id"] = event.id
        dict["rsvp_status"] = event.rsvpStatus
        EventController().getEventDetail(event.id, callback: { [self] (obj) in
            var home = UINavigationController()
            let swiftUIView = EventDetailVC(eventsModel:obj, isEventFor: "suggestedEvents", selectedIdx: 0, dismissAction: {
                    self.dismiss(animated: true)
                }
            )

            
            let homeViewController = UIHostingController(rootView: swiftUIView)
            home = UINavigationController(rootViewController: homeViewController)
            home.modalPresentationStyle = .fullScreen
            home.navigationBar.isHidden = false
            self.present(home, animated: true)
        })
    }
    //MARK: - Dynamic Content width set
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == interestCollection {
            let lblName = UILabel(frame: CGRect.zero)
            lblName.text = swipeInfo.interests[indexPath.item].interest
            lblName.font = UIFont(name: "Avenir-Medium", size: 12)
            lblName.textAlignment = .center
            lblName.sizeToFit()
          
            return CGSize(width: lblName.frame.width + 30, height: 32)
        }else{
        return CGSize(width: 176, height: 96)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == interestCollection {
            return 0
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == interestCollection {
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        }else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
}
extension CLLocationDistance {
    func inMiles() -> CLLocationDistance {
        return self*0.00062137
    }

    func inKilometers() -> CLLocationDistance {
        return self/1000
    }
}
extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

}
class HostingController: UIHostingController<AnyView> {

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AnyView(EmptyView()))
    }
}
