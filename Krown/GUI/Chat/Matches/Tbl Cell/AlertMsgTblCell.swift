//
//  AlertMsgTblCell.swift
//  Krown
//
//  Created by macOS on 02/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class AlertMsgTblCell: UITableViewCell {
    
    @IBOutlet weak var lbl_bottom: UILabel!
    @IBOutlet weak var lbl_top: UILabel!
    @IBOutlet weak var btn_action: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
