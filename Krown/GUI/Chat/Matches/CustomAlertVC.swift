//
//  CustomAlertVC.swift
//  Krown
//
//  Created by macOS on 01/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class CustomAlertVC: UIViewController {

    var matchesChatVC : MatchesChatVC?
    var matchesChatViewVC : MatchesChatViewVC?
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var TblView: UITableView!
    @IBOutlet weak var alertBottom: NSLayoutConstraint!
    @IBOutlet weak var tbl_height: NSLayoutConstraint!
    var isFromSwiftUI : Bool = false
    var strImgArr : [[String:Any]] = [[String:Any]]()
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    
    var isPresenting = false



    override func viewDidLoad() {
        super.viewDidLoad()
        v1.layer.cornerRadius = 14
        v1.layer.masksToBounds = true
        TblView.delegate = self
        TblView.dataSource = self
        TblView.register(UINib(nibName: "AlertMsgTblCell", bundle: nil), forCellReuseIdentifier: "AlertMsgTblCell")
        tbl_height.constant = CGFloat(strImgArr.count * 60)
        // Do any additional setup after loading the view.
    }
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension CustomAlertVC: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            alertBottom.constant = -500
            self.view.layoutIfNeeded()
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.alertBottom.constant = 16.0
                self.backdropView.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.alertBottom.constant = -500
                self.backdropView.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}


extension CustomAlertVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strImgArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlertMsgTblCell = tableView.dequeueReusableCell(withIdentifier: "AlertMsgTblCell", for: indexPath) as! AlertMsgTblCell
        if indexPath.row == 0 {
            cell.lbl_top.isHidden = true
        } else if indexPath.row == (strImgArr.count - 1) {
            cell.lbl_bottom.isHidden = true
        }
        if let str : String = strImgArr[indexPath.row]["value"] as? String {
            cell.btn_action.setTitle(str, for: .normal)
        } else if let img : UIImage = strImgArr[indexPath.row]["value"] as? UIImage {
            cell.btn_action.setImage(img, for: .normal)
        }
        cell.btn_action.tag = indexPath.row
        cell.btn_action.addTarget(self, action: #selector(alertAction(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    @objc func alertAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { [self] in
            if let action : String = strImgArr[sender.tag]["action"] as? String {
                if let vc : MatchesChatVC = matchesChatVC {
                    vc.actionSheetResponse(action)
                } else if let vc : MatchesChatViewVC = matchesChatViewVC {
                    vc.actionSheetResponse(action)
                }
            }
        })
    }
}
