//
//  SettingsVC.swift
//  Krown
//
//  Created by macOS on 28/12/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI
import MBProgressHUD

class SettingsVC: UIViewController {

    // MARK: - UITextField Outlets
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    // MARK: - UIView Outlets
    @IBOutlet weak var numberBgView: UIView!
    @IBOutlet weak var emailBgView: UIView!

    // MARK: - UISwitch Outlets
    @IBOutlet weak var accountSwitch: UISwitch!
    
    // MARK: - UILabel Outlets
    @IBOutlet weak var accountStatusLabel: UILabel!
    @IBOutlet weak var accountStatusBrif: UILabel!
    
    // MARK: - Variables
    private var timer = Timer()
    private var differenceInSeconds = Int()
    
    // MARK: - ViewController Mathods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tabBarController?.tabBar.layer.zPosition = -1
//        self.tabBarController?.tabBar.alpha = 0
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Custom Mathods
    private func initialSetup() {
        accountSwitch.setOn(false, animated: false)
        numberBgView.layer.borderWidth = 2
        numberBgView.layer.borderColor = UIColor.darkWinterSky.cgColor
        numberBgView.layer.cornerRadius = 15
        numberTextField.placeholder = "+4512345678"
        numberTextField.isUserInteractionEnabled = false
        numberTextField.delegate = self
        
        emailBgView.layer.borderWidth = 2
        emailBgView.layer.borderColor = UIColor.darkWinterSky.cgColor
        emailBgView.layer.cornerRadius = 15
        emailTextField.placeholder = "email@email.com"
        emailTextField.isUserInteractionEnabled = false
        emailTextField.delegate = self
        let email: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.email) as! String
        emailTextField.text = email
        getProfileData()
        setAccountStatus()
        getPreferences()
    }
    
    func setAccountStatus() {
        if accountSwitch.isOn {
            MainController().pauseProfile(paused_for: "24:00:00", callback: { [self] (response) in
                accountStatusLabel.text = "Paused"
                getPreferences()
            })
        } else {
            accountStatusLabel.text = "Pause"
            accountStatusBrif.text = "Pausing account will hide your profile from protential matches. You can still chat with your current matches."
        }
    }

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
                        accountSwitch.setOn(true, animated: true)
                        updateCounting()
                        UserDefaults.standard.setValue(true, forKey: WebKeyhandler.User.isPaused)
                        UserDefaults.standard.synchronize()
                        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
                            updateCounting()
                        })
                    }
                }
            }
        })
    }
    func activateAccount()
    {
        MainController().pauseProfile(paused_for: "00:00:00", callback: { [self] (response) in
            accountStatusLabel.text = "Pause"
            accountStatusBrif.text = "Pausing account will hide your profile from protential matches. You can still chat with your current matches."
            UserDefaults.standard.setValue(false, forKey: WebKeyhandler.User.isPaused)
            UserDefaults.standard.synchronize()
            accountSwitch.setOn(false, animated: true)
            self.timer.invalidate()
        })
    }
    
    func updateCounting(){
        let (h, m, _) = differenceInSeconds.secondsToHoursMinutesSeconds()
        accountStatusBrif.text = "\(h) hours \(m) minutes until re-activating"
        differenceInSeconds -= 10
        if differenceInSeconds < 1
        {
            self.timer.invalidate()
            activateAccount()
        }
    }

    func getProfileData() {
        let ownUserID = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        MainController().getProfile(userID: ownUserID, callback: { [self] (obj) in
            // Toast is shown
            globalConstant.personObject = obj
            numberTextField.text = globalConstant.personObject.phone_number
            emailTextField.text = globalConstant.personObject.email
        })
    }
    // MARK: - UISwitch Action
    @IBAction func accountStatusAction(_ sender: UISwitch) {
        if !sender.isOn {
            activateAccount()
        }
        setAccountStatus()
    }
    
    // MARK: - UIButton Action
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEditAction(_ sender: UIButton) {
        if sender.tag == 1 {
            //Phone
            numberTextField.isUserInteractionEnabled = true
            numberTextField.becomeFirstResponder()
        } else if sender.tag == 2 {
            //Email
            emailTextField.isUserInteractionEnabled = true
            emailTextField.becomeFirstResponder()
        }
    }

    @IBAction func btnActions(_ sender: UIButton) {
        if sender.tag == 1 {
            //Notifications
            let swiftUIView = NotificationVC()
            let homeViewController = UIHostingController(rootView: swiftUIView)
            self.navigationController?.pushViewController(homeViewController, animated: true)
        } else if sender.tag == 2 {
            //Terms of service
            let vc = AppStoryboard.loadWebVC()
            vc.headline = "Terms Of Service"
            vc.url = URLHandler.termsOfService
            present(vc, animated: true, completion: nil)
        } else if sender.tag == 3 {
            //Privacy Policy
            let vc = AppStoryboard.loadWebVC()
            vc.headline = "Privacy Policy"
            vc.url = URLHandler.privacy
            present(vc, animated: true, completion: nil)
        } else if sender.tag == 4 {
            //My Data
            let swiftUIView = MyDataVC()
            let homeViewController = UIHostingController(rootView: swiftUIView)
            self.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
    
}

extension SettingsVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == numberTextField {
            numberTextField.isUserInteractionEnabled = false
        } else if textField == emailTextField {
            emailTextField.isUserInteractionEnabled = false
        }
        if numberTextField.text != globalConstant.personObject.phone_number || emailTextField.text != globalConstant.personObject.email {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            SettingsController().update_phone_email(phone_number: numberTextField.text ?? "", email: emailTextField.text ?? "") { [self] (responseString) in
                MBProgressHUD.hide(for: self.view, animated: true)
                AlertController().notifyUser(title: "", message: responseString.capitalized.replacingOccurrences(of: "_", with: " "), timeToDissapear: 2)
                getProfileData()
            }
        }
    }
}

extension Int {
    func secondsToHoursMinutesSeconds() -> (Int, Int, Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
}
