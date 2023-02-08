//
//  YourChatTblCell.swift
//  Krown
//
//  Created by macOS on 01/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class YourChatTblCell: UITableViewCell {

    @IBOutlet weak var view_your: UIView!
    @IBOutlet weak var view_other: UIView!
    @IBOutlet weak var lbl_your: UILabel!
    @IBOutlet weak var lbl_other: UILabel!
    @IBOutlet weak var view_chat_your: UIView!
    @IBOutlet weak var view_chat_other: UIView!
    @IBOutlet weak var imgOther: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        view_chat_your.layer.cornerRadius = 20
        view_chat_other.layer.cornerRadius = 20
        imgOther.layer.cornerRadius = 20
        imgOther.contentMode = .scaleAspectFill
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
