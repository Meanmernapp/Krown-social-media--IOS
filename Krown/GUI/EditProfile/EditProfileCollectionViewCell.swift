//
//  EditProfileCollectionViewCell.swift
//  Krown
//
//  Created by Anders Teglgaard on 06/12/2017.
//  Copyright © 2017 Nicklas Ridell. All rights reserved.
//

import UIKit

class EditProfileCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    var looperImage: Looper? {
        didSet {
            configLooperImage()
        }
    }
    func configLooperImage() {
        looperImage?.start(in: profileImage.layer)

    }
    override func awakeFromNib() {

    }

    override func prepareForReuse() {
        looperImage?.stop()
    }

}
