//
//  SwipeEventListCell.swift
//  Krown
//
//  Created by Anders Teglgaard on 19/11/2017.
//  Copyright © 2017 Nicklas Ridell. All rights reserved.
//

import UIKit

class SwipeEventListCell: UITableViewCell {

    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventAttendingCount: UILabel!
    @IBOutlet weak var eventStartingTime: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var heightOfEventImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var mutualAttendLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
