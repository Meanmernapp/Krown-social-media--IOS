//
//  ShareVC.swift
//  Krown
//
//  Created by Anders Teglgaard on 30/01/2017.
//  Copyright © 2017 KrownUnity. All rights reserved.
//

import UIKit
import Branch
import KYCircularProgress
import Koloda
import AlamofireImage
import Alamofire

class ShareVC: UIViewController {

    private var progress: UInt8 = 0
    private var pointsArr = [Double]()
    private var nextRewardPoint = Double(0)
    var kolodaVenue = NSDictionary()
    var numberOfCards: Int = 0
    @IBOutlet weak var pointsToNextReward: UILabel!
    @IBOutlet weak var lastRewardsText: UILabel!
    @IBOutlet weak var lastRewardsPoints: UILabel!
    @IBOutlet fileprivate weak var RewardCircularProgress: KYCircularProgress!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    var kolodaRedeemView = KolodaRedeemView()

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        // Setup of KolodaView
        kolodaView.dataSource = self
        kolodaView.delegate = self
        // Hides the view until needed
        kolodaView.isHidden = true

        loadRewards()
        getCreditHistory()

        getVenues()
        configureRewardCircularProgress()
        Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)

    }

    private func loadRewards() {
        // Check how many points the user has on the branch server
        Branch.getInstance().loadRewards { (_, _) in
            // changed boolean will indicate if the balance changed from what is currently in memory

            // will return the balance of the current user's credits
            let credits = Branch.getInstance().getCredits()
            //print(NSLocalizedString("The Credits on the accounts are: \(credits)", comment: "Tester that can be deleted"))
            self.pointsLbl.text = String(Int(self.nextRewardPoint)-credits)
        }

    }

    private func getCreditHistory() {
        Branch.getInstance().getCreditHistory { (_, error) in
            if error == nil {
                // process history

                // TODO: Find latest point of history

                // TODO: Get Points and set lastRewardsPoints

                // From latest point in history set the user creds up
                let mainController = MainController()
                mainController.getProfile(userID: "10154260958043998", callback: { (response) in
                    //print(response)
                    self.lastRewardsText.text = String("\(response.name) signed up")
                })

            }
        }
    }
    private func getVenues() {
        // Calls the webService to check which venues has offers now
        MainController.shared.getShareVenues { (response) in

            let venues = response.object(forKey: "Venues") as! NSArray

            /////// THIS PART IS FOR SETTING KOLODA VIEW///////
            ////// It needs to be revised when an update is done TODO marked////
            // TODO: if data has not yet been loaded and redeem button is clicked then we will have a crash
            self.kolodaVenue = venues[0] as! NSDictionary
            //////////////////////////////////////////////////

            for venue in venues as! [NSDictionary] {
                self.pointsArr.append((venue.object(forKey: "Points_cost")! as! NSString).doubleValue)
            }

            self.pointsArr = self.pointsArr.sorted()

            // Setup next Reward points
            for point in self.pointsArr {
                if point >= self.RewardCircularProgress.progress {
                    self.nextRewardPoint = point
                    break
                }
            }
        }
    }

    private func configureRewardCircularProgress() {

        RewardCircularProgress.delegate = self
        RewardCircularProgress.colors = [UIColor.darkGray]

        RewardCircularProgress.progressChanged {
            (progress: Double, _: KYCircularProgress) in
            self.pointsToNextReward.text = "\(Int(self.nextRewardPoint * progress)) / \(Int(self.nextRewardPoint))"

        }

    }

    @objc private func updateProgress() {
        progress = progress &+ 1
        let normalizedProgress = Double(progress) / Double(UInt8.max)

        RewardCircularProgress.progress = normalizedProgress
    }

    @IBAction func RedeemButtonAction(_ sender: Any) {
        numberOfCards = 1
        // This just clears the current card index and reloads the view so the button can be clicked more than once
        kolodaView.resetCurrentCardIndex()
        kolodaView.isHidden = false

    }
    @IBAction func shareBtn(_ sender: Any) {

        // Creates the branch universal object
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "ShareLink/")
        branchUniversalObject.title = "Download Krown"
        branchUniversalObject.contentDescription = "Pre-Planned Dates Made Simple and Fun"
        branchUniversalObject.imageUrl = "http://www.krownapp.com/files/Krown-Logo.png"
        // branchUniversalObject.addMetadataKey("property1", value: "blue")
        // branchUniversalObject.addMetadataKey("property2", value: "red")

        // Creates the linkProperties for the branch universal object
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        linkProperties.channel = "App"
        linkProperties.addControlParam("$desktop_url", withValue: "http://download.krownapp.com/")
        linkProperties.addControlParam("$ios_url", withValue: "http://download.krownapp.com/")
        linkProperties.addControlParam("$android_url", withValue: "http://download.krownapp.com/")

        branchUniversalObject.showShareSheet(with: linkProperties,
                                             andShareText: "Hey try Krown, it is simple pre-planned dating",
                                             from: self) { (activityType, completed) in
                                                if completed {
                                                    //print(String(format: "Completed sharing to %@", activityType!))
                                                } else {
                                                    //print("Link sharing cancelled")
                                                }
        }

    }

}
extension ShareVC: KYCircularProgressDelegate {
    func progressChanged(progress: Double, circularProgress: KYCircularProgress) {

        }
    }

extension ShareVC: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // Hides the view so it is possible to click again on the UI Below
        kolodaView.isHidden = true

    }

    func koloda(koloda: KolodaView, didSelectCardAt index: Int) {
    }
}

extension ShareVC: KolodaViewDataSource {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return numberOfCards

    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        kolodaRedeemView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KolodaRedeemView") as! KolodaRedeemView

        kolodaRedeemView.view.layer.cornerRadius = 20
        kolodaRedeemView.logoImage.layer.cornerRadius = 50

        kolodaRedeemView.descriptionText.text = kolodaVenue.object(forKey: "Description") as? String
        kolodaRedeemView.openingHoursLabel.text = kolodaVenue.object(forKey: "Opening_hours") as! String?
        kolodaRedeemView.pointsLabel.text = String("\(kolodaVenue.object(forKey: "Points_cost")!) Points")
        kolodaRedeemView.titleText.text = kolodaVenue.object(forKey: "Title") as! String?
        //Add authentication header
        var coverImageUrlRequest = URLRequest(url: URL(string: kolodaVenue.object(forKey: "Cover_image_url") as! String)!)
        var coverHeaders: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            coverHeaders = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            coverHeaders = [.authorization(bearerToken: "ForceRefresh"),]
        }
        coverImageUrlRequest.headers = coverHeaders
        kolodaRedeemView.coverImage.af.setImage(withURLRequest: coverImageUrlRequest)
        //Add authentication header
        var logoImageUrlRequest = URLRequest(url: URL(string: kolodaVenue.object(forKey: "Logo_url") as! String)!)
        var logoHeaders: HTTPHeaders
        if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
            logoHeaders = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
        } else {
            logoHeaders = [.authorization(bearerToken: "ForceRefresh"),]
        }
        logoImageUrlRequest.headers = logoHeaders
        kolodaRedeemView.logoImage.af.setImage(withURLRequest: logoImageUrlRequest)
        

        koloda.addSubview(kolodaRedeemView.view)
        addChild(kolodaRedeemView)
        kolodaRedeemView.didMove(toParent: self)
        kolodaRedeemView.view.translatesAutoresizingMaskIntoConstraints = false

        return kolodaRedeemView.view
    }

}
