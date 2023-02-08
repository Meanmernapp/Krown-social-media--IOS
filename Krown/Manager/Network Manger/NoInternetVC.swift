import UIKit

class NoInternetVC: UIViewController {

    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var alertView: UIView!

    typealias COMPLETION = () -> Void
    var completion: COMPLETION?

    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 10
        alertView.clipsToBounds = true

        tryAgainBtn.addTarget(self, action: #selector(tapOnTryAgain), for: .touchUpInside)
    }

    @objc func tapOnTryAgain() {
        completion?()
    }

}
