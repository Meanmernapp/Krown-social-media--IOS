//
//  SwipeEventListVC.swift
//  
//
//  Created by Anders Teglgaard on 19/11/2017.
//

import UIKit
import MBProgressHUD
import AlamofireImage
import Alamofire


class SwipeEventListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func backBtn(_ sender: Any) {
        removeSubview()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!

    var swipeInfo: PersonObject!
    var isShowInterst : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Customization
        // TODO: BUG when this view is openend more than once the background is becoming darker. Might affect memory.
        self.view.layer.cornerRadius = 20
        self.tableView.layer.cornerRadius = 20
        backgroundView.blurImageDark()
        backgroundView.layer.cornerRadius = 20
        backgroundView.clipsToBounds = true

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return swipeInfo.events.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SwipeEventListCell", for: indexPath) as! SwipeEventListCell

        cell.eventTitleLbl.text = swipeInfo!.events[indexPath.row].title
        cell.eventDescription.text = swipeInfo.events[indexPath.row].description
        cell.eventAttendingCount.text = swipeInfo.events[indexPath.row].totalAttending

        switch swipeInfo.events[indexPath.row].rsvpStatus {
        case "attending":
            cell.mutualAttendLbl.text = "You and \(swipeInfo.name) both attend this event"
        case "unsure":
            cell.mutualAttendLbl.text = "\(swipeInfo.name) is interested in the event you are attending"
        default:
            cell.mutualAttendLbl.text = ""
        }

        // Time set to readable format
        let df = DateFormatter()
        // Wed Dec 01 17:08:03 +0000 2010
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        let date = df.date(from: swipeInfo.events[indexPath.row].timeStart)
        df.dateFormat = "eee dd/MM yyyy"
        let dateStr = df.string(from: date!)
        cell.eventStartingTime.text = dateStr

        // image set
        let imageUrl = URL(string: swipeInfo.events[indexPath.row].imageURL)!
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
                if case .failure = imageResponse.result {
                    // Sets the height of the image to zero if no image present
                    cell.heightOfEventImageConstraint.constant = 0
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
        })

        imageView.frame = cell.eventImage.frame
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        cell.eventImage.addSubview(imageView)

        return cell

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func removeSubview() {
        //print("Start remove subview")
        if let viewWithTag = self.view.viewWithTag(200) {
            UIView.animate(withDuration: 0.2, animations: {
                viewWithTag.frame = CGRect(x: viewWithTag.frame.maxX-viewWithTag.frame.width, y: -viewWithTag.frame.maxY, width: viewWithTag.frame.width, height: viewWithTag.frame.height)
            }, completion: { _ in
                            viewWithTag.removeFromSuperview()
                            let swipeDetailVC = self.parent as! SwipeDetailVC
                            swipeDetailVC.refreshData()
                            swipeDetailVC.view.sendSubviewToBack(swipeDetailVC.eventContainerView)
                            let containerView = swipeDetailVC.profileContainerView
                            let infoView = swipeDetailVC.infoView
                            let infoView2 = swipeDetailVC.vwInfo2
//                            let eventInfoView = swipeDetailVC.eventInfoView

                            containerView?.isHidden = true
                            //infoView?.isHidden = false
                if self.isShowInterst{
                    infoView?.isHidden = true
                    infoView2?.isHidden = false
                }
                else{
                    infoView?.isHidden = false
                    infoView2?.isHidden = true
                }

                            // If the swiped user is attending mutual events
//                            if swipeDetailVC.swipeInfo.events.count >= 1 {
//                            eventInfoView?.isHidden = false
//                            } else {
//                            eventInfoView?.isHidden = true
//                            }
            })
            // Removes the added childViewController to remove it from memory
            // parent?.children.first?.removeFromParent()

        } else {
            //print("No!")
        }
    }
}
