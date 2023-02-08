//
//  TableViewEventCell.swift
//  Krown
//
//  Created by KrownUnity on 16/02/17.
//  Copyright © 2017 KrownUnity. All rights reserved.
//

import UIKit

class MenuTableViewEventCell: UITableViewCell {

    @IBOutlet weak var FrontPicture: UIImageView!
    @IBOutlet weak var commonFriendsCount: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var backgroundPicture: UIImageView!
    var userID: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        FrontPicture.layer.masksToBounds = false
        FrontPicture.layer.cornerRadius = FrontPicture.frame.width/2
        FrontPicture.clipsToBounds = true

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
