//
//  KolodaRedeemView.swift
//  Krown
//
//  Created by Anders Teglgaard on 09/02/2017.
//  Copyright © 2017 KrownUnity. All rights reserved.
//

import UIKit

class KolodaRedeemView: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var coverImage: UIImageView!

    @IBOutlet weak var bottomUiView: UIView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    roundCornersOfLowestElements()

    }
    func roundCornersOfLowestElements() {
        let path = UIBezierPath(roundedRect: bottomUiView.bounds,
                                byRoundingCorners: [.bottomRight, .bottomLeft],
                                cornerRadii: CGSize(width: 20, height: 20))

        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath
        bottomUiView.layer.mask = maskLayer
    }
    @IBAction func redeemButtonAction(_ sender: Any) {

    }

}
