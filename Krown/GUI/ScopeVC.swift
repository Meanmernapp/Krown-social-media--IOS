//
//  ScopeVC.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import CoreGraphics
import RangeSeekSlider
import Alamofire

class ScopeVC: UIViewController {
    
    // @IBOutlet weak var AgeRangeLeadingConstarint: NSLayoutConstraint!
    // @IBOutlet weak var lblRadiusNumberLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBoth: UIButton!
    @IBOutlet weak var btnWomen: UIButton!
    @IBOutlet weak var btnMen: UIButton!
    
    @IBOutlet weak var btnFriends: UIButton!
    @IBOutlet weak var btnUnrelated: UIButton!
    @IBOutlet weak var btnFriendsOfFriends: UIButton!
    
    
    var mainController: MainController = MainController()
    // @IBOutlet weak var sexPref: UISegmentedControl!
    @IBOutlet weak var minAge: UILabel!
    @IBOutlet weak var maxAge: UILabel!
    @IBOutlet weak var ageRangeSliderOutlet: RangeSeekSlider!
    @IBOutlet weak var radiusNumber: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    // @IBOutlet weak var profilePic: UIImageView!
    // @IBOutlet weak var unrelatedBtn: UIButton!
    // @IBOutlet weak var friendsfriendsBtn: UIButton!
    //@IBOutlet weak var friendsBtn: UIButton!
    
    var friendsBool = 1
    var friendsFriendsBool = 1
    var unrelatedBool = 1
    
    var prefMen = false
    var prefWom = false
    var prefBoth = true
    
    var looper: Looper? {
        didSet {
            configLooper()
        }
    }
    
    override func viewDidLoad() {
        lblTitle.text = "Discovery Filters"
        
        ageRangeSliderOutlet.delegate = self
        
        btnFriendsOfFriends.layer.cornerRadius = 15
        btnFriendsOfFriends.layer.borderWidth = 1
        btnUnrelated.layer.cornerRadius = 15
        btnUnrelated.layer.borderWidth = 1
        btnFriends.layer.cornerRadius = 15
        btnFriends.layer.borderWidth = 1
        
        btnMen.layer.cornerRadius = 15
        btnMen.layer.borderWidth = 1
        btnWomen.layer.cornerRadius = 15
        btnWomen.layer.borderWidth = 1
        btnBoth.layer.cornerRadius = 15
        btnBoth.layer.borderWidth = 1
        
        self.btnMen.layer.borderColor = UIColor.lightGray.cgColor
        self.btnWomen.layer.borderColor = UIColor.lightGray.cgColor
        self.btnBoth.layer.borderColor = UIColor.lightGray.cgColor
        
        let placeholderImage = UIImage(named: "man.jpg")!
        if let profilePictures = UserDefaults.standard.object(forKey: WebKeyhandler.User.profilePic) {
            if let profilePicture = (profilePictures as! [String]).first {
                let url = URL(string: profilePicture)!
                
                if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                    
                    looper = PlayerLooper(videoURL: url, loopCount: -1)
                    
                } else {
                    //Add authentication header
                    var imageUrlRequest = URLRequest(url: url)
                    var headers: HTTPHeaders
                    if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                        headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
                    } else {
                        headers = [.authorization(bearerToken: "ForceRefresh"),]
                    }
                    imageUrlRequest.headers = headers
                    // profilePic.af.setImage(withURLRequest: imageUrlRequest, placeholderImage: placeholderImage)
                }
            }
            
        }
        
        /*  profilePic.layer.masksToBounds = false
         profilePic.layer.cornerRadius = profilePic.frame.width/2
         profilePic.clipsToBounds = true*/
        tabBarController?.tabBar.isHidden = true
        /*  friendsBtn.layer.cornerRadius = friendsBtn.frame.width/2
         friendsfriendsBtn.layer.cornerRadius = friendsfriendsBtn.frame.width/2
         unrelatedBtn.layer.cornerRadius = unrelatedBtn.frame.width/2
         
         sexPref.layer.cornerRadius = 5
         
         var rect: CGRect = self.sexPref.frame
         rect.size.height = 40.0
         self.sexPref.frame = rect*/
        loadScope()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    func configLooper() {
        // looper?.start(in: profilePic.layer)
    }
    
    func loadScope() {
        let main = mainController
        main.getScopeInfo(callback: {
            (response) in
            let preferences = response.object(forKey: "Preferences") as! NSDictionary
            
            if preferences.object(forKey: WebKeyhandler.Preferences.prefSex) != nil {
                
                let prefSex = preferences[WebKeyhandler.Preferences.prefSex] as! String
                let lowerAge = preferences[WebKeyhandler.Preferences.lowerAge] as! String
                let upperAge = preferences[WebKeyhandler.Preferences.upperAge] as! String
                let prefRadius = preferences[WebKeyhandler.Preferences.prefRadius] as! String
                let discFriends = preferences["preference_discover_friends"] as! String
                let discFriendsFriends = preferences["preference_discover_friends_friends"] as! String
                let discUnrelated = preferences["preference_discover_unrelated"] as! String
                
                if prefSex == "1"{
                    self.btnMen.setTitleColor(UIColor.royalPurple, for: .normal)
                    self.btnMen.layer.borderColor = UIColor.royalPurple.cgColor
                    self.btnMen.backgroundColor = UIColor.darkWinterSky
                    self.btnMen.setImage(UIImage(named:  "↳Color"), for: .normal)
                    self.prefMen = true
                    self.prefWom = false
                    self.prefBoth = false
                } else if prefSex == "2" {
                    self.btnWomen.setTitleColor(UIColor.royalPurple, for: .normal)
                    self.btnWomen.layer.borderColor = UIColor.royalPurple.cgColor
                    self.btnWomen.backgroundColor = UIColor.darkWinterSky
                    self.btnWomen.setImage(UIImage(named:  "↳Color"), for: .normal)
                    //  self.sexPref.selectedSegmentIndex = 1
                    self.prefMen = false
                    self.prefWom = true
                    self.prefBoth = false
                } else if prefSex == "3" {
                    self.btnBoth.setTitleColor(UIColor.royalPurple, for: .normal)
                    self.btnBoth.layer.borderColor = UIColor.royalPurple.cgColor
                    self.btnBoth.backgroundColor = UIColor.darkWinterSky
                    self.btnBoth.setImage(UIImage(named:  "↳Color"), for: .normal)
                    // self.sexPref.selectedSegmentIndex = 2
                    self.prefMen = false
                    self.prefWom = false
                    self.prefBoth = true
                }else {
                    self.btnMen.layer.borderColor = UIColor.lightGray.cgColor
                    self.btnMen.backgroundColor = UIColor.white
                    self.btnMen.setTitleColor(UIColor.slateGrey, for: .normal)
                    self.btnWomen.layer.borderColor = UIColor.lightGray.cgColor
                    self.btnWomen.backgroundColor = UIColor.white
                    self.btnWomen.setTitleColor(UIColor.slateGrey, for: .normal)
                    self.btnBoth.layer.borderColor = UIColor.lightGray.cgColor
                    self.btnBoth.backgroundColor = UIColor.white
                    self.btnBoth.setTitleColor(UIColor.slateGrey, for: .normal)
                }
                if discFriends == "1"{
                    self.btnFriends.layer.borderColor = UIColor.royalPurple.cgColor
                    self.btnFriends.backgroundColor = UIColor.darkWinterSky
                    self.btnFriends.setTitleColor(UIColor.royalPurple, for: .normal)
                    self.friendsBool = 1
                } else {
                    self.btnFriends.layer.borderColor = UIColor.lightGray.cgColor
                    self.btnFriends.backgroundColor = UIColor.white
                    self.btnFriends.setTitleColor(UIColor.slateGrey, for: .normal)
                    self.friendsBool = 0
                }
                if discFriendsFriends == "1"{
                    self.btnFriendsOfFriends.layer.borderColor = UIColor.royalPurple.cgColor
                    self.btnFriendsOfFriends.backgroundColor = UIColor.darkWinterSky
                    self.btnFriendsOfFriends.setTitleColor(UIColor.royalPurple, for: .normal)
                    self.friendsFriendsBool = 1
                } else {
                    self.btnFriendsOfFriends.backgroundColor = UIColor.white
                    self.btnFriendsOfFriends.layer.borderColor = UIColor.lightGray.cgColor
                    self.btnFriendsOfFriends.setTitleColor(UIColor.slateGrey, for: .normal)
                    self.friendsFriendsBool = 0
                }
                if discUnrelated == "1"{
                    self.btnUnrelated.layer.borderColor = UIColor.royalPurple.cgColor
                    self.btnUnrelated.backgroundColor = UIColor.darkWinterSky
                    self.btnUnrelated.setTitleColor(UIColor.royalPurple, for: .normal)
                    self.unrelatedBool = 1
                } else {
                    self.btnUnrelated.backgroundColor = UIColor.white
                    self.btnUnrelated.layer.borderColor = UIColor.lightGray.cgColor
                    self.btnUnrelated.setTitleColor(UIColor.slateGrey, for: .normal)
                    self.unrelatedBool = 0
                }
                
                self.minAge.text = lowerAge
                self.maxAge.text = upperAge
                guard let safeLowerAge = NumberFormatter().number(from: lowerAge) else { return }
                guard let safeUpperAge = NumberFormatter().number(from: upperAge) else { return }
                
                /*  let width = self.view.frame.size.width/100;
                 let base = Float(lowerAge)! - 18
                 let diff = (Float(upperAge)!-Float(lowerAge)!)/2
                 let final = Float(Float(base+diff) * Float(width))
                 let value = Float(lowerAge)! > 90 ? Float(final)-20 : (Float(upperAge)! < 31 ? final+20 :final)
                 self.AgeRangeLeadingConstarint.constant = CGFloat(value)
                 */
                
                self.ageRangeSliderOutlet.selectedMinValue = CGFloat(truncating: safeLowerAge)
                self.ageRangeSliderOutlet.selectedMaxValue = CGFloat(truncating: safeUpperAge)
                self.ageRangeSliderOutlet.layoutSubviews()
                
                self.radiusSlider.setValue(Float(prefRadius)!, animated: true)
                self.radiusNumber.text = prefRadius+"km"
                //  self.lblRadiusNumberLeadingConstraint.constant = CGFloat(Float(prefRadius)!)
            }
            
        })
    }
    
    
    @IBAction func btnInterestedIn(_ sender: UIButton) {
        if sender.tag == 1 {
            btnMen.layer.borderColor = UIColor.lightGray.cgColor
            self.btnMen.backgroundColor = UIColor.white
            
            btnWomen.layer.borderColor = UIColor.lightGray.cgColor
            self.btnWomen.backgroundColor = UIColor.white
            
            btnBoth.layer.borderColor = UIColor.lightGray.cgColor
            self.btnBoth.backgroundColor = UIColor.white
            
            
            btnMen.setTitleColor(UIColor.slateGrey, for: .normal)
            btnWomen.setTitleColor(UIColor.slateGrey, for: .normal)
            btnBoth.setTitleColor(UIColor.slateGrey, for: .normal)
            sender.setTitleColor(UIColor.royalPurple, for: .normal)
            btnMen.setImage(UIImage(systemName: ""), for: .normal)
            btnWomen.setImage(UIImage(systemName: ""), for: .normal)
            btnBoth.setImage(UIImage(systemName: ""), for: .normal)
            sender.layer.borderColor = UIColor.royalPurple.cgColor
            sender.backgroundColor = UIColor.darkWinterSky
            
            sender.setImage(UIImage(named:  "↳Color"), for: .normal)
        } else {
            btnMen.setImage(UIImage(systemName: ""), for: .normal)
            btnWomen.setImage(UIImage(systemName: ""), for: .normal)
            btnBoth.setImage(UIImage(systemName: ""), for: .normal)
            btnMen.layer.borderColor = UIColor.lightGray.cgColor
            self.btnMen.backgroundColor = UIColor.white
            
            btnWomen.layer.borderColor = UIColor.lightGray.cgColor
            self.btnWomen.backgroundColor = UIColor.white
            
            btnBoth.layer.borderColor = UIColor.lightGray.cgColor
            self.btnBoth.backgroundColor = UIColor.white
            
            btnMen.setTitleColor(UIColor.slateGrey, for: .normal)
            btnWomen.setTitleColor(UIColor.slateGrey, for: .normal)
            btnBoth.setTitleColor(UIColor.slateGrey, for: .normal)
            sender.setTitleColor(UIColor.royalPurple, for: .normal)
            sender.layer.borderColor = UIColor.royalPurple.cgColor
            sender.backgroundColor = UIColor.darkWinterSky
            sender.setImage(UIImage(named:  "↳Color"), for: .normal)
        }
        switch sender {
        case btnMen:
            prefMen = true
            prefWom = false
            prefBoth = false
        case btnWomen:
            prefMen = false
            prefWom = true
            prefBoth = false
        case btnBoth :
            prefMen = false
            prefWom = false
            prefBoth = true
        default:
            break
        }
    }
    
    @IBAction func infoBtn(_ sender: Any) {
        let message = "Sort your social circles by turning on or off friends, friends' friends or those who are unrelated. Turning off a social circle hides you from them, and them from you. Use this if you for example do not want to see close friends or familiy. If you would rather date someone who knows a common friend or if you just want to explore completely on your own without relations knowing."
        AlertController().displayInfo(title: "Social Circles", message: message)
    }
    
    @IBAction func radiusSlider(_ sender: Any) {
        radiusNumber.text = String(Int(radiusSlider.value))+"km"
        // lblRadiusNumberLeadingConstraint.constant = CGFloat(Float(radiusSlider.value))
    }
    
    @IBAction func friendsBtn(_ sender: Any) {
        if friendsBool == 1 {
            if friendsFriendsBool == 0 && unrelatedBool == 0 {
                AlertController().displayInfo(title: "Discover and be seen by", message: "Please select at least one.")
            }else{
                btnFriends.layer.borderColor = UIColor.lightGray.cgColor
                self.btnFriends.backgroundColor = UIColor.white
                btnFriends.setTitleColor(UIColor.slateGrey, for: .normal)
                friendsBool = 0
            }
        } else {
            btnFriends.layer.borderColor = UIColor.royalPurple.cgColor
            btnFriends.backgroundColor = UIColor.darkWinterSky
            btnFriends.setTitleColor(UIColor.royalPurple, for: .normal)
            friendsBool = 1
        }
    }
    @IBAction func friendsFriendsBtn(_ sender: Any) {
        if friendsFriendsBool == 1 {
            if friendsBool == 0 && unrelatedBool == 0 {
                AlertController().displayInfo(title: "Discover and be seen by", message: "Please select at least one.")
            }else{
                self.btnFriendsOfFriends.backgroundColor = UIColor.white
                btnFriendsOfFriends.layer.borderColor = UIColor.lightGray.cgColor
                btnFriendsOfFriends.setTitleColor(UIColor.slateGrey, for: .normal)
                friendsFriendsBool = 0
            }
        } else {
            btnFriendsOfFriends.layer.borderColor = UIColor.royalPurple.cgColor
            btnFriendsOfFriends.backgroundColor = UIColor.darkWinterSky
            btnFriendsOfFriends.setTitleColor(UIColor.royalPurple, for: .normal)
            friendsFriendsBool = 1
        }
        
    }
    @IBAction func unrelatedBtn(_ sender: Any) {
        if unrelatedBool == 1 {
            if friendsBool == 0 && friendsFriendsBool == 0 {
                AlertController().displayInfo(title: "Discover and be seen by", message: "Please select at least one.")
            }else{
                self.btnUnrelated.backgroundColor = UIColor.white
                btnUnrelated.layer.borderColor = UIColor.lightGray.cgColor
                btnUnrelated.setTitleColor(UIColor.slateGrey, for: .normal)
                unrelatedBool = 0
            }
        } else {
            btnUnrelated.layer.borderColor = UIColor.royalPurple.cgColor
            btnUnrelated.backgroundColor = UIColor.darkWinterSky
            btnUnrelated.setTitleColor(UIColor.royalPurple, for: .normal)
            unrelatedBool = 1
        }
        
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        
        let main = mainController
        var scopeDict = [String: AnyObject]()
        if prefMen {
            scopeDict[WebKeyhandler.Preferences.prefSex] = "1" as AnyObject?
        } else if prefWom {
            scopeDict[WebKeyhandler.Preferences.prefSex] = "2" as AnyObject?
        } else if prefBoth {
            scopeDict[WebKeyhandler.Preferences.prefSex] = "3" as AnyObject?
        }
        scopeDict[WebKeyhandler.Preferences.lowerAge] = minAge.text as AnyObject?
        scopeDict[WebKeyhandler.Preferences.upperAge] = maxAge.text as AnyObject?
        scopeDict[WebKeyhandler.Preferences.prefRadius] = Int(radiusSlider.value) as AnyObject?
        if friendsBool == 1 {
            scopeDict[WebKeyhandler.Preferences.discFriends] = "1" as AnyObject?
        } else {
            scopeDict[WebKeyhandler.Preferences.discFriends] = "0"  as AnyObject?
        }
        if friendsFriendsBool == 1 {
            scopeDict[WebKeyhandler.Preferences.discFriendsFriends] = "1" as AnyObject?
        } else {
            scopeDict[WebKeyhandler.Preferences.discFriendsFriends] = "0"  as AnyObject?
        }
        if unrelatedBool == 1 {
            scopeDict[WebKeyhandler.Preferences.discUnrelated] = "1" as AnyObject?
        } else {
            scopeDict[WebKeyhandler.Preferences.discUnrelated] = "0"  as AnyObject?
        }
        
        main.updateScopeInfo(scopeDict: scopeDict as NSDictionary) { (_) in
            NotificationCenter.default.post(name: .resetAndRefreshDataSourceForSwipes, object: nil)
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
// MARK: - RangeSeekSliderDelegate

extension ScopeVC: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === ageRangeSliderOutlet {
            maxAge.text = String(describing: Int(maxValue))
            minAge.text = String(describing: Int(minValue))
            /*  let width = self.view.frame.size.width/100
             let base = minValue-18
             let diff = (maxValue-minValue)/2
             let final = CGFloat((base+diff) * width)
             let value = minValue > 90 ? final-20 : (maxValue < 31 ? final+20 :final)
             //  let value = minValue > 90 ? final-(width*5.33) : (maxValue < 31 ? final+(width*5.33):final)
             
             AgeRangeLeadingConstarint.constant = value*/
        }
    }
}
