//
//  LoginVC.swift
//  
//
//  Created by KrownUnity on 01/09/16.
//
//
/*
import UIKit
import AVFoundation
import AVKit
import SwiftEntryKit
import FBSDKCoreKit
import FBSDKLoginKit
import SDWebImage

class LoginVC: UIViewController, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        //After completing login GDPR popup is removed
        SwiftEntryKit.dismiss()
//        mainController.loginOld(self)

    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {

    }

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var textScrollView: UIScrollView!
    @IBOutlet weak var loginVideoView: UIImageView!
//    let facebookLoginButton = FBLoginButton(frame: .zero, permissions: [.publicProfile,.userBirthday,.email,.userPhotos,.userEvents,.userFriends,.userGender])

    let mainController = MainController()
    var timer = Timer()
    var looper: AVPlayerLooper?

    private let attributes: EKAttributes = {
        var attributes =  EKAttributes()
        attributes = .centerFloat
        attributes.windowLevel = .alerts
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = EKAttributes.BackgroundStyle.color(color: EKColor(light: UIColor(white: 100.0/255.0, alpha: 0.3), dark: UIColor(white: 100.0/255.0, alpha: 0.3)) )
        attributes.entryBackground = EKAttributes.BackgroundStyle.color(color: EKColor(light: UIColor.white, dark: UIColor.white))
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.displayDuration = .infinity
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        return attributes
    }()

    override func viewWillAppear(_ animated: Bool) {

    }

    override func viewDidLoad() {
//        facebookLoginButton.delegate = self
//        facebookLoginButton.isHidden = true
        globalConstant.loginVC = self
    }

    override func viewDidAppear(_ animated: Bool) {
        // Location updating when open app -> It has in one instance started creating an exc bad acces error
        // mainController.requestLocationAuth(viewController: self)
        if (UserDefaults.standard.object(forKey: UserDefaultsKeyHandler.Login.userLogin)) == nil {

            
            
            // setupTextScrollView has to be setup here or else it will break the constraints due to autolayout is applied just after viewdidload
            self.setupTextScrollView()
            self.playVideo()

        } else {
            let homeViewController = AppStoryboard.loadHomeVC()
            homeViewController.modalPresentationStyle = .overCurrentContext
            homeViewController.loadView()
            homeViewController.mainController = self.mainController
            navigationController?.pushViewController(homeViewController, animated: true)

            // TODO: This should always be run to update logintimes and session tokens - how to make it work without fb opening
//            mainController.loginOld(self)
        }
    }

    @IBAction func privacyBtn(_ sender: AnyObject) {
        let vc = AppStoryboard.loadLoginInfoVC()
        let navigation = UINavigationController(rootViewController: vc)
        navigation.modalPresentationStyle = .overCurrentContext
        navigation.isNavigationBarHidden = true
        present(navigation, animated: true, completion: nil)
    }

    @IBAction func tosButton(_ sender: AnyObject) {
        let vc = AppStoryboard.loadWebVC()
        vc.headline = "Terms Of Service"
        vc.url = URLHandler.termsOfService
        present(vc, animated: true, completion: nil)
    }

    @IBAction func ppButton(_ sender: AnyObject) {
        let vc = AppStoryboard.loadWebVC()
        vc.headline = "Privacy Policy"
        vc.url = URLHandler.privacy
        present(vc, animated: true, completion: nil)
    }

    @IBAction func facebookBtnClick(_ sender: AnyObject) {
        // Generate textual content
        let simpleMessage = EKSimpleMessage.createSimpleMessage(
            titleText: "Agreements",
            descriptionText: "Do you agree to the Terms and Service, and the Privacy Policy.",
            titleStyle: .init(font: MainFont.medium.withUI(size: 15), color: .  black, alignment: .center),
            descriptionStyle: .init(font: MainFont.light.withUI(size: 13), color: .black, alignment: .center),
            imageName: "gdprCompliant", imageSize: CGSize(width: 50, height: 50),
            imageContentMode: .scaleAspectFit
        )

        // Generate buttons content
        let buttonFont = MainFont.medium.withUI(size: 16)

        // Agree Button
        let okButtonLabel = EKProperty.createButtonLabel(font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black), text: "Agree")
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray)) {
//            self.facebookLoginButton.sendActions(for: .touchUpInside)

            SwiftEntryKit.dismiss {
//                self.mainController.loginOld(self)
            }
        }

        // Disagree Button
        let disagreeButtonLabel = EKProperty.createButtonLabel(font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black), text: "Disagree")
        let disagreeButton = EKProperty.ButtonContent(label: disagreeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray)) {
            SwiftEntryKit.dismiss()
        }

        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, disagreeButton, separatorColor: EKColor(light: UIColor.gray, dark: UIColor.gray), expandAnimatedly: true)

        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)

        // Setup the view itself
        let contentView = EKAlertMessageView(with: alertMessage)

        // Setup Attributes
        SwiftEntryKit.display(entry: contentView, using: attributes)

    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func playVideo() {
        // "https://krownunity.com/api/storage/profile_images/5FlOkaKIPy57ZN02FRCLpVZ9Cn9tW564bHZu9jBG.mp4"
        let videoURL = URL(string: URLHandler.API_URL + "api/storage/introvideo/introVideo.mp4")!
        let playerItem = AVPlayerItem(url: videoURL)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: queuePlayer)

        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.player = queuePlayer

        looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.loginVideoView.layer.addSublayer(playerLayer)
        queuePlayer.volume = 0.0
        // avoids the player to send it to a connected apple tv
        queuePlayer.allowsExternalPlayback = false
        queuePlayer.play()

        UIView.animate(withDuration: 1, animations: {() -> Void in
            self.loginVideoView.alpha = 0
            self.loginVideoView.alpha = 1
        }, completion: {(_: Bool) -> Void in
        })
    }

    func  setupTextScrollView() {

        let textForScroll = ["In Krown you find other users going to the events as you",
                             "Krown lets you meet people with the same interests, doing what you also love to do",
                             "No more awkward coffee dates, there is always something going on when you meet",
                             "Love discovering new things with new people, then Krown will change your world",
                             "Don't want to be see your X in the app? We got you covered by sorting social circles"]

        textScrollView.showsHorizontalScrollIndicator = false
        textScrollView.showsVerticalScrollIndicator = false
        let scrollViewWidth: CGFloat = textScrollView.frame.width
        let scrollViewHeight: CGFloat = textScrollView.frame.height
        var counter: CGFloat = 0

        for text in textForScroll {
            let textView = UITextView(frame: CGRect(x: scrollViewWidth*counter, y: 0, width: scrollViewWidth, height: scrollViewHeight))
            textView.text = text
            textView.textAlignment = .center
            textView.textColor = UIColor.white
            textView.backgroundColor = UIColor.clear
            textView.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
            textView.isScrollEnabled = false
            textView.isSelectable = false

            counter += 1
            textScrollView.addSubview(textView)

        }
        textScrollView.contentSize = CGSize(width: self.textScrollView.frame.width * counter, height: self.textScrollView.frame.height)

        self.textScrollView.delegate = self
        self.pageControl.currentPage = 0
        self.pageControl.numberOfPages = Int(counter)

        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }

    @objc func moveToNextPage () {

        let pageWidth: CGFloat = self.textScrollView.frame.width
        // todo: needs to receive the counter so the number of pages will be displayed
        let maxWidth: CGFloat = pageWidth * 5
        let contentOffset: CGFloat = self.textScrollView.contentOffset.x

        var slideToX = contentOffset + pageWidth

        if  contentOffset + pageWidth == maxWidth {
            slideToX = 0
        }
        self.textScrollView.scrollRectToVisible(CGRect(x: slideToX, y: 0, width: pageWidth, height: self.textScrollView.frame.height), animated: true)
    }

    // MARK: UIScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        changePageControl(scrollView: scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        changePageControl(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }

    func changePageControl(scrollView: UIScrollView) {
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth: CGFloat = scrollView.frame.width
        let currentPage: CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage)
    }

}
*/
