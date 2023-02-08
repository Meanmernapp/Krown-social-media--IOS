//
//  menuSuggestedEventCard.swift
//  Krown
//
//  Created by Anders Teglgaard on 23/02/2018.
//  Copyright © 2018 KrownUnity. All rights reserved.
//

import UIKit
import MBProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class MenuSuggestedEventCard: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    var event: EventObject!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var attendBtn: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var attendBtnView: UIView!
    @IBOutlet weak var attendBtnLbl: UILabel!
    var menuVCNeedsRefresh = false

    @IBAction func attendBtnAction(_ sender: Any) {
        attendEvent()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        attendBtn.layer.cornerRadius = 20
    }

    override func viewDidDisappear(_ animated: Bool) {
        if menuVCNeedsRefresh {
            NotificationCenter.default.post(name: .refreshMenuVC, object: nil)
        }
    }

    func setEvent(event: EventObject) {
        self.event = event
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "SuggestedEventCell", for: indexPath) as? SuggestedEventCell)!
        cell.eventTitleLbl.text = event.title
        cell.eventDescription.text = event.description
        cell.eventAttendingCount.text = event.totalAttending

        // Time set to readable format
        let dateFormatter = DateFormatter()
        // Wed Dec 01 17:08:03 +0000 2010
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        let date = dateFormatter.date(from: event.timeStart)
        dateFormatter.dateFormat = "eee dd/MM/yy"
        let dateStr = dateFormatter.string(from: date!)
        cell.eventStartingTime.text = dateStr

        // Does the event contain an imageURL? else it skips this part
        if let imageUrl = URL(string: event.imageURL) {
                let imageView: UIImageView = UIImageView()
                MBProgressHUD.showAdded(to: imageView, animated: true)
            //Add authentication header
            var imageUrlRequest = URLRequest(url: imageUrl)
            var headers: HTTPHeaders
            if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
            } else {
                headers = [.authorization(bearerToken: "ForceRefresh"),]
            }
            imageUrlRequest.headers = headers
            imageView.af.setImage(
                    withURLRequest: imageUrlRequest,
                    placeholderImage: nil,
                    imageTransition: .crossDissolve(0.2), completion: { (imageResponse) in
                        MBProgressHUD.hide(for: imageView, animated: true)
                        // If the server cant respond with imageData
                        if imageResponse.error != nil {
                            // Sets the height of the image to zero if no image present
                            cell.heightOfEventImageConstraint.constant = 0
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                })

                imageView.frame = cell.eventImage.frame
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                cell.eventImage.addSubview(imageView)

        } else {
            cell.eventImage.isHidden = true
            cell.heightOfEventImageConstraint.constant = 0
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func attendEvent() {
        let main = MainController()
        main.attendEvent(event: event)
        attendBtnLbl.text = "Attending"
        menuVCNeedsRefresh = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event.attendingMatches!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commonFriendsCollectionCell", for: indexPath)
        if let view = cell as? ProfileDetailsCommonFriendsCollectionViewCell {
            let attendee = event.attendingMatches![indexPath.row]
            //Add authentication header
            var imageUrlRequest = URLRequest(url: URL(string: attendee.imageArray[0])!)
            var headers: HTTPHeaders
            if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
            } else {
                headers = [.authorization(bearerToken: "ForceRefresh"),]
            }
            imageUrlRequest.headers = headers
            view.imageView.af.setImage(withURLRequest: imageUrlRequest)
            view.nameLabel.text = attendee.name
        }
        return cell
    }

}
