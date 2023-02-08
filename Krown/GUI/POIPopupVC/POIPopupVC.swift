//
//  POIPopupVC.swift
//  Krown
//
//  Created by Apple on 01/10/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftUI
import MapKit

class POIPopupVC: UIViewController {
    
    //MARK: - outlet
    @IBOutlet weak var vwParent: UIView!
    @IBOutlet weak var vwPopup: UIView!
    
    @IBOutlet weak var imgEvent: UIImageView!
    @IBOutlet weak var imgUser1: UIImageView!
    @IBOutlet weak var imgUser2: UIImageView!
    @IBOutlet weak var imgUser3: UIImageView!
    
    @IBOutlet weak var vwLastImg: UIView!
    
    @IBOutlet weak var vwUserList: UIView!
    
    @IBOutlet weak var lblEventName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblSpecials: UILabel!
    
    @IBOutlet weak var tvSpecialValue: UITextView!
    
    @IBOutlet weak var userListVwWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userListVwHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var specialValueHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var specialHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var userListTosuperViewConstraint: NSLayoutConstraint!
    
   // @IBOutlet weak var lblSpecialValue: UILabel!
    @IBOutlet weak var lblRemaining: UILabel!
    
    //MARK: - variable
    var dictLocation : POILocationModel?
    var arrImg : [UIImage] = [UIImage(named: "close")!,UIImage(named: "Compass Selected straigth")!,UIImage(named: "button_add")!,UIImage(named: "Add")!,]
    var arrPersonsAtPOI = [MatchesModel]()
    
    //MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupData()
    }

    override func viewDidAppear(_ animated: Bool) {
//        MBProgressHUD.showAdded(to: self.view, animated: true)
        MainController.shared.liveDatingAtPOI(poiID: dictLocation?.id ?? "0") { [self] dict in
            if dict["ErrorCode"] as! String != "You need to be active at POI to find users"  && dict["ErrorCode"] as! String != "No users found at POI" {
                let activeUsersAtPOIArray = dict["ActiveUsersAtPOI"] as! NSArray
                PersonController().matchObjectArray(activeUsersAtPOIArray, callback: { activeUsersAtPOI in
                    arrPersonsAtPOI = activeUsersAtPOI
                    setImageView()
                })
            } else if dict["ErrorCode"] as! String == "No users found at POI" {
                AlertController().notifyUser(title: "No Singles Found", message: "Try again when someone new has entered", timeToDissapear: 5)
                setImageView()
            }
            else{
                setImageView()
            }
//            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    //MARK: - setup view
    func setupView(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        vwParent.addGestureRecognizer(tap)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.3, delay:
                    0.3, options: [], animations: {
                self.vwParent.backgroundColor = .slateGrey.withAlphaComponent(0.5)

            })
        }
        vwPopup.layer.cornerRadius = 20
        vwPopup.clipsToBounds = true
        userListVwHeightConstraint.constant = 0
    }
    
    //MARK: - Textview height calculation
    func setSpecialValuesHeight()
    {
        let numLines : CGFloat = (tvSpecialValue.contentSize.height / (tvSpecialValue.font?.lineHeight ?? 20))
        
        let maxScrollHeight = UIScreen.main.bounds.height * 0.40
        let txtViewHeight = 28 + CGFloat((numLines * 18))
        
        if(txtViewHeight < maxScrollHeight)
        {
            specialValueHeightConstraint.constant = txtViewHeight
        }else{
            specialValueHeightConstraint.constant = maxScrollHeight
        }
        
        tvSpecialValue.layoutIfNeeded()
    }
   
    //MARK: - setup data
    func setupData()
    {
        imgEvent.sd_setImage(with: URL(string: (dictLocation?.logoImageURL == "" ? dictLocation?.locationBackground : dictLocation?.logoImageURL) ?? "" ), placeholderImage: UIImage(named: "imagePlaceholder"))
        lblEventName.text = dictLocation?.placeName == "" || dictLocation?.placeName == nil ? "-" : dictLocation?.placeName
        lblTime.text = setDay()
        if (dictLocation?.placeStreet == "" || dictLocation?.placeStreet == nil) &&
            (dictLocation?.placeCity == "" || dictLocation?.placeCity == nil){
            lblAddress.text = "Direction"
        }else{
            lblAddress.text = (dictLocation?.placeStreet ?? "") + ", " + (dictLocation?.placeCity ?? "")
        }
        
        if dictLocation?.promotionalText == "" || dictLocation?.promotionalText == nil {
            lblSpecials.isHidden = true
            tvSpecialValue.isHidden = true
            tvSpecialValue.text = ""
            specialValueHeightConstraint.constant = 0
            specialHeightConstraint.constant = 0
            
        }else{
            tvSpecialValue.isHidden = false
            tvSpecialValue.text = dictLocation?.promotionalText ?? ""

            specialHeightConstraint.constant = 24
            specialValueHeightConstraint.constant = 25
            setSpecialValuesHeight()
        }
        
    }
    
    func setDay() -> String{
        let day = Date().dayNumberOfWeek()
        var time = ""
        switch day {
        case 1 : time = "\(((dictLocation?.openingHoursSunFrom == "" || dictLocation?.openingHoursSunFrom == nil) ? ("00:00") : (dictLocation?.openingHoursSunFrom?.substring(with: 0..<6))) ?? "00:00") - \(((dictLocation?.openingHoursSunTo == "" || dictLocation?.openingHoursSunTo == nil) ? ("00:00") : (dictLocation?.openingHoursSunTo?.substring(with: 0..<6))) ?? "00:00")"
                return "Sun - \(time)"
        case 2 : time = "\(((dictLocation?.openingHoursMonFrom == "" || dictLocation?.openingHoursMonFrom == nil) ? ("00:00") : (dictLocation?.openingHoursMonFrom?.substring(with: 0..<6))) ?? "00:00") - \(((dictLocation?.openingHoursMonTo == "" || dictLocation?.openingHoursMonTo == nil) ? ("00:00") : (dictLocation?.openingHoursMonTo?.substring(with: 0..<6))) ?? "00:00")"
                return "Mon - \(time)"
        case 3 : time = "\(((dictLocation?.openingHoursTueFrom == "" || dictLocation?.openingHoursTueFrom == nil) ? ("00:00") : (dictLocation?.openingHoursTueFrom?.substring(with: 0..<6))) ?? "00:00") - \(((dictLocation?.openingHoursTueTo == "" || dictLocation?.openingHoursTueTo == nil) ? ("00:00") : (dictLocation?.openingHoursTueTo?.substring(with: 0..<6))) ?? "00:00")"
                return "Tue - \(time)"
        case 4 : time = "\(((dictLocation?.openingHoursWedFrom == "" || dictLocation?.openingHoursWedFrom == nil) ? ("00:00") : (dictLocation?.openingHoursWedFrom?.substring(with: 0..<6))) ?? "00:00") - \(((dictLocation?.openingHoursWedTo == "" || dictLocation?.openingHoursWedTo == nil) ? ("00:00") : (dictLocation?.openingHoursWedTo?.substring(with: 0..<6))) ?? "00:00")"
                return "Wed - \(time)"
        case 5 : time = "\(((dictLocation?.openingHoursThuFrom == "" || dictLocation?.openingHoursThuFrom == nil) ? ("00:00") : (dictLocation?.openingHoursThuFrom?.substring(with: 0..<6))) ?? "00:00") - \(((dictLocation?.openingHoursThuTo == "" || dictLocation?.openingHoursThuTo == nil) ? ("00:00") : (dictLocation?.openingHoursThuTo?.substring(with: 0..<6))) ?? "00:00")"
                return "Thu - \(time)"
        case 6 : time = "\(((dictLocation?.openingHoursFriFrom == "" || dictLocation?.openingHoursFriFrom == nil) ? ("00:00") : (dictLocation?.openingHoursFriFrom?.substring(with: 0..<6))) ?? "00:00") - \(((dictLocation?.openingHoursFriTo == "" || dictLocation?.openingHoursFriTo == nil) ? ("00:00") : (dictLocation?.openingHoursFriTo?.substring(with: 0..<6))) ?? "00:00")"
                return "Fri - \(time)"
        case 7 : time = "\(((dictLocation?.openingHoursSatFrom == "" || dictLocation?.openingHoursSatFrom == nil) ? ("00:00") : (dictLocation?.openingHoursSatFrom?.substring(with: 0..<6))) ?? "00:00") - \(((dictLocation?.openingHoursSatTo == "" || dictLocation?.openingHoursSatTo == nil) ? ("00:00") : (dictLocation?.openingHoursSatTo?.substring(with: 0..<6))) ?? "00:00")"
                return "Sat - \(time)"
            case .none:
                return "00:00 - 00:00"
            case .some(_):
                return "00:00 - 00:00"
        }
    }
    func setImageView(){
        if arrPersonsAtPOI.count > 0{
            vwLastImg.isHidden = true
            vwUserList.isHidden = false
            userListVwHeightConstraint.constant = 40
            if arrPersonsAtPOI.count > 3{
                
                ((arrPersonsAtPOI[0].profile_pic_url?.count ?? 0) >  0) ?  (imgUser1.sd_setImage(with: URL(string: arrPersonsAtPOI[0].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser1.image = UIImage(named: "imagePlaceholder"))
                ((arrPersonsAtPOI[1].profile_pic_url?.count ?? 0) >  0) ?  (imgUser2.sd_setImage(with: URL(string: arrPersonsAtPOI[1].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser2.image = UIImage(named: "imagePlaceholder"))
                
                imgUser3.isHidden = true
                vwLastImg.isHidden = false
                lblRemaining.text = "\(arrPersonsAtPOI.count-2)+"
            }
            else if arrPersonsAtPOI.count == 3 {
                ((arrPersonsAtPOI[0].profile_pic_url?.count ?? 0) >  0) ?  (imgUser1.sd_setImage(with: URL(string: arrPersonsAtPOI[0].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser1.image = UIImage(named: "imagePlaceholder"))
                ((arrPersonsAtPOI[1].profile_pic_url?.count ?? 0) >  0) ?  (imgUser2.sd_setImage(with: URL(string: arrPersonsAtPOI[1].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser2.image = UIImage(named: "imagePlaceholder"))
                ((arrPersonsAtPOI[2].profile_pic_url?.count ?? 0) >  0) ?  (imgUser3.sd_setImage(with: URL(string: arrPersonsAtPOI[2].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser3.image = UIImage(named: "imagePlaceholder"))
            }
            else if arrPersonsAtPOI.count == 2{
                imgUser1.isHidden = true
                ((arrPersonsAtPOI[0].profile_pic_url?.count ?? 0) >  0) ?  (imgUser2.sd_setImage(with: URL(string: arrPersonsAtPOI[0].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser2.image = UIImage(named: "imagePlaceholder"))
                ((arrPersonsAtPOI[1].profile_pic_url?.count ?? 0) >  0) ?  (imgUser3.sd_setImage(with: URL(string: arrPersonsAtPOI[1].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser3.image = UIImage(named: "imagePlaceholder"))
            }
            else if arrPersonsAtPOI.count == 1 {
                imgUser1.isHidden = true
                imgUser2.isHidden = true
                ((arrPersonsAtPOI[0].profile_pic_url?.count ?? 0) >  0) ?  (imgUser3.sd_setImage(with: URL(string: arrPersonsAtPOI[0].profile_pic_url?[0].image_url ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"))) : (imgUser3.image = UIImage(named: "imagePlaceholder"))
            }
          
        }
        else{
            userListVwHeightConstraint.constant = 0
            vwUserList.isHidden = true
        }
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissView()
    }

    
    func dismissView(){
        let dismissalTime = 0.3
        UIView.animate(withDuration: dismissalTime) {
            self.vwParent.backgroundColor = .slateGrey.withAlphaComponent(0.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+dismissalTime) {
            self.dismiss(animated: true)
        }
    }
    
    
    //MARK: - button clicks
    
    @IBAction func btnMoveToListClicked(_ sender: UIButton) {
        if !imgUser1.isHidden || !imgUser2.isHidden || !imgUser3.isHidden {
            let swiftUIView = ListPeopleViews(matchesModel: arrPersonsAtPOI, isEventFor: "", viewType: viewtype.nearbyView)
          let hostingController = UIHostingController(rootView: swiftUIView)
          hostingController.modalPresentationStyle = .overCurrentContext
          let wave = UINavigationController(rootViewController: hostingController)
          wave.modalPresentationStyle = .overCurrentContext
        
          if var topController = UIApplication.shared.keyWindow?.rootViewController  {
              while let presentedViewController = topController.presentedViewController {
                  topController = presentedViewController
              }
           topController.present(wave, animated: true, completion: nil)
          }
        }
       
    }
    @IBAction func btnRedirectToMapClicked(_ sender: UIButton) {
        let latitude: CLLocationDegrees = NSString(string: (dictLocation?.placeLatitude)!).doubleValue
        let longitude: CLLocationDegrees = NSString(string: (dictLocation?.placeLongitude)!).doubleValue
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = dictLocation?.placeName ?? "Location"
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func btnInfoClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        dismissView()
    }
}

