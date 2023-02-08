//
//  TableViewReuseableCell.swift
//  Krown
//
//  Created by KrownUnity on 06/10/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import QuartzCore

class ChatListVCTableViewCell: UITableViewCell {

    @IBOutlet weak var FrontPicture: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var badge: UILabel!
    var matchObject: MatchObject!
    var looperFrontImage: Looper? {
        didSet {
            configLooperFrontImage()
        }
    }
    func configLooperFrontImage() {
        looperFrontImage?.start(in: FrontPicture.layer)

    }

    var looperBackgroundImage: Looper? {
        didSet {
            configLooperBackgroundImage()
        }
    }
    func configLooperBackgroundImage() {
        looperBackgroundImage?.start(in: backgroundPicture.layer)

    }

    override func awakeFromNib() {
        super.awakeFromNib()

        FrontPicture.layer.masksToBounds = false
        FrontPicture.layer.cornerRadius = FrontPicture.frame.width/2
        FrontPicture.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        looperFrontImage?.stop()
        looperBackgroundImage?.stop()
        lastMessageLbl.text = ""
        dateLbl.text = ""
        FrontPicture.image = nil
        backgroundPicture.image = nil
        badge.text = ""
        badge.backgroundColor = .clear
    }

}
