//
//  SuggestedEventCell.swift
//  Krown
//
//  Created by Anders Teglgaard on 25/02/2018.
//  Copyright © 2018 KrownUnity. All rights reserved.
//

import UIKit

class SuggestedEventCell: UITableViewCell {
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventAttendingCount: UILabel!
    @IBOutlet weak var eventStartingTime: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var heightOfEventImageConstraint: NSLayoutConstraint!

    @IBOutlet weak var attendeeCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
