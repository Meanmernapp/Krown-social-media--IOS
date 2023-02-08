//
//  EventCollCell.swift
//  Krown
//
//  Created by macOS on 20/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class EventCollCell: UICollectionViewCell {

    @IBOutlet weak var imgEvent: UIImageView!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_month: UILabel!
    @IBOutlet weak var lbl_event_title: UILabel!
    @IBOutlet weak var lbl_location: UILabel!
    @IBOutlet weak var btn_event: UIButton!
    @IBOutlet weak var viewDate: UIView! {
        didSet {
            viewDate.layer.cornerRadius = 5
            viewDate.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var bgView: UIView! {
        didSet {
            bgView.layer.cornerRadius = 10
            bgView.layer.masksToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
