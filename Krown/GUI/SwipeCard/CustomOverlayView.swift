//
//  CustomOverlayView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/27/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"
private let declineRedOverlay = "DeclineRed"
private let acceptGreenOverlay = "AcceptGreen"

class CustomOverlayView: OverlayView {

//    @IBOutlet weak var declineRed: UIImageView!
    @IBOutlet weak var acceptGreen: UIImageView!

    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in

        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        return imageView
    }() {
        didSet {
            overlayImageView.layer.cornerRadius = 16
        }
    }

    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                //print("Is Swipe Left")
                overlayImageView.image = nil
                overlayImageView.alpha = 0.6
                overlayImageView.backgroundColor = UIColor.opacityForOverlay
//                 overlayImageView.image = UIImage(named: overlayLeftImageName)
                acceptGreen.image = UIImage(named: "Ignore Icon")//acceptGreenOverlay)
//                declineRed.image = nil
            case .right? :
                //print("Is Swipe \(isSwipeWave ? "Wave" : "Right")")
                overlayImageView.image = nil
                overlayImageView.alpha = 0.6
                overlayImageView.backgroundColor = UIColor.darkWinterSky
//                 overlayImageView.image = UIImage(named: overlayRightImageName)
                acceptGreen.image = UIImage(named: globalConstant.isSwipeWave ? "HandWaving" : "Checkmark")//declineRedOverlay)
//                acceptGreen.image = nil

            default:
                //print("Is Swipe default")
                overlayImageView.image = nil
                overlayImageView.alpha = 0.6
                overlayImageView.backgroundColor = UIColor.darkWinterSky
//                declineRed.image = nil
                acceptGreen.image = nil
            }

        }
    }

}
