//
// Install Cocoapods
// pod 'ReachabilitySwift'
//

import Foundation
import Alamofire

class NetworkManager: NSObject {

    static let shared = NetworkManager()
    private var networkManager: NetworkReachabilityManager?
    private let queue = DispatchQueue.global()
    private override init() {
        networkManager = NetworkReachabilityManager(host: "www.google.com")
    }

    func startMonitoring() {
        networkManager?.startListening(onQueue: queue, onUpdatePerforming: { status in
            switch status {
            case .unknown:
                Log.log(message: "Internet status unknown", type: .info, category: "Internet Connectivity", content: "")
            case .notReachable:
                Log.log(message: "Internet not reachable", type: .info, category: "Internet Connectivity", content: "")
                self.showFullScreenPopupForNointernet(true)
            case .reachable(.cellular), .reachable(.ethernetOrWiFi):
                Log.log(message: "Internet reachable", type: .info, category: "Internet Connectivity", content: "")
                self.showFullScreenPopupForNointernet(false)
            }
        })
    }

    func stopMonitoring() {
        networkManager?.stopListening()
        Log.log(message: "DEBUG: stop monitoring %@", type: .debug, category: Category.networking, content: "")

    }

    func showFullScreenPopupForNointernet(_ isShow: Bool) {
        DispatchQueue.main.async {
            if isShow {
                if let topController = UIApplication.topViewController() {

                    if topController is NoInternetVC {
                        // Ignore Case
                    } else {
                        let noInternetVC  = AppStoryboard.noInternetVC()
                        noInternetVC.modalPresentationStyle = .overFullScreen
                        topController.present(noInternetVC, animated: false, completion: nil)
                    }

                }
            } else {
                if let topController = UIApplication.topViewController() {
                    if topController is NoInternetVC {
                        topController.dismiss(animated: false, completion: nil)
                    }
                }
            }
        }
    }
}
