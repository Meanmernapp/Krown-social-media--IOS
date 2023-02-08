//
//  ProfileDetailsCommonFriendsCollectionViewCell.swift
//  Krown
//
//  Created by Anders Teglgaard on 23/11/2017.
//

import UIKit

class ProfileDetailsCommonFriendsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        self.makeItCircle()
    }

    func makeItCircle() {
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius  = CGFloat(roundf(Float(self.imageView.frame.size.width/2.0)))
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.darkGray.cgColor
    }
}
