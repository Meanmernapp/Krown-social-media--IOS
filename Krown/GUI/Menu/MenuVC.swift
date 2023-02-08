////
////  MenuVC.swift
////  Krown
////
////  Created by KrownUnity on 01/09/16.
////  Copyright © 2016 KrownUnity. All rights reserved.
////
//
//import UIKit
//import Alamofire
//import SwiftUI
//
//class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
//
//    @IBOutlet weak var kolodaView: UIView!
//
//    @IBOutlet weak var tableView: UITableView!
//
//    var mainController: MainController = MainController()
//    var events: [EventObject] = []
//    var popOverSuggestedEvent = UIViewController()
//    let webServiceController = WebServiceController.shared
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Setup observer for refresh
//        NotificationCenter.default.addObserver(self, selector: #selector(MenuVC.reloadMenu), name: .refreshMenuVC, object: nil)
//
//        reloadMenu()
//
//    }
//    override func viewDidAppear(_ animated: Bool) {
//
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = false
//    }
//    @IBAction func showHeatmapBtn(_ sender: Any) {
//        let vc = AppStoryboard.loadHeatMapVC()
//        let navigation = UINavigationController(rootViewController: vc)
//        navigation.isNavigationBarHidden = true
//        present(navigation, animated: true, completion: nil)
//    }
//
//    @IBAction func takeVideoBtn(_ sender: Any) {
//        let vc = AppStoryboard.loadTakeVideoVC()
//        let navigation = UINavigationController(rootViewController: vc)
//        navigation.isNavigationBarHidden = true
//        present(navigation, animated: true, completion: nil)
//    }
//
//    @IBAction func editProfile(_ button: UIButton) {
//        let vc = AppStoryboard.loadEditProfileVC()
//        let navigation = UINavigationController(rootViewController: vc)
//        navigation.isNavigationBarHidden = true
//        present(navigation, animated: true, completion: nil)
//    }
//
//    @objc func goToScope(button: UIButton) {
//        
//       // let vc = AppStoryboard.loadScopeVC()
//      //  vc.mainController = mainController
//       /* let navigation = UINavigationController(rootViewController: swiftUIView as! UIViewController)
//        navigation.isNavigationBarHidden = true
//        present(navigation, animated: true, completion: nil)*/
//        
//        let hostingController = UIHostingController(rootView: ScopeVCSwiftUIBridge())
//        navigationController?.isNavigationBarHidden = false
//        navigationController?.modalPresentationStyle = .fullScreen
//        present(hostingController, animated: true, completion: nil)
//        //navigationController?.pushViewController(hostingController, animated: true)
//    }
//
//    @objc func goToShareScreen(button: UIButton) {
//        let vc = AppStoryboard.loadShareVC()
//        let navigation = UINavigationController(rootViewController: vc)
//        navigation.isNavigationBarHidden = true
//        present(navigation, animated: true, completion: nil)
//    }
//
////    @objc func goToPreferences(button: UIButton) {
////        let vc = AppStoryboard.loadPreferencesVC()
////        let navigation = UINavigationController(rootViewController: vc)
////        navigation.isNavigationBarHidden = true
////        present(navigation, animated: true, completion: nil)
////    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//            if segue.identifier == "popOverSuggestedEvent" {
//                let popOverSuggestedEvent = segue.destination as! popOverSuggestedEvent
//                let event = sender as! EventObject
//                popOverSuggestedEvent.event = event
//            }
//
//    }
//
//    @objc func reloadMenu() {
//    // Retrieve events that others are attending that you yourself is not
//    let main = mainController
//        main.distributeEventArrayFromMatched(UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String, callback: {
//    (response) in
//    self.events = response
//    if response.count > 0 {
//    // TODO: Show the suggested events label if there are any or hide if theres none
//    }
//    self.refreshMenu()
//    })
//    }
//
//    func refreshMenu() {
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if events.count < 1 {
//            return 1
//        } else {
//        return (events.count + 1)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        switch indexPath.row {
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MenuTableViewMainCell
//            cell.awakeFromNib()
//            cell.scopeBtn.addTarget(self, action: #selector(MenuVC.goToScope), for: .touchUpInside)
//            cell.shareBtn.addTarget(self, action: #selector(MenuVC.goToShareScreen), for: .touchUpInside)
//            cell.prefBtn.addTarget(self, action: #selector(MenuVC.goToPreferences), for: .touchUpInside)
//            if events.count == 0 {
//                cell.suggestedEventsLbl.text = "   Currently no suggested events"
//            } else {
//                cell.suggestedEventsLbl.text = "   Suggested events"
//            }
//            return cell
//        default:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! MenuTableViewEventCell
//            let eventIndex = indexPath.row-1 // minus 1 because the events array starts at 0
//            cell.nameLbl.text = events[eventIndex].title
//            cell.commonFriendsCount.text = String(describing: events[eventIndex].attendingMatches!.count)
//            let placeholderImage = UIImage(named: "man.jpg")!
//            if let url = URL(string: events[eventIndex].imageURL) {
//                //Add authentication header
//                var imageUrlRequest = URLRequest(url: url)
//                var headers: HTTPHeaders
//                if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
//                    headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
//                } else {
//                    headers = [.authorization(bearerToken: "ForceRefresh"),]
//                }
//                imageUrlRequest.headers = headers
//                cell.backgroundPicture.af.setImage(withURLRequest: imageUrlRequest, placeholderImage: placeholderImage)
//                cell.FrontPicture.af.setImage(withURLRequest: imageUrlRequest, placeholderImage: placeholderImage)
//            }
//
//            return cell
//        }
//
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row != 0 {
//            tableView.deselectRow(at: indexPath, animated: true)
//
//            let vc = AppStoryboard.loadSuggestedEventVC()
//            vc.event = events[indexPath.row-1]
//            let navigation = UINavigationController(rootViewController: vc)
//            navigation.isNavigationBarHidden = true
//            present(navigation, animated: true, completion: nil)
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        switch indexPath.row {
//        case 0:
//            return 290
//        default:
//            return 62
//        }
//    }
//
//}
