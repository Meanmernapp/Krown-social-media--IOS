//
//  FeedbackImgCell.swift
//  Krown
//
//  Created by Mac Mini 2020 on 19/05/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class FeedbackImgCell: UICollectionViewCell {
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
         super.awakeFromNib()
         self.img.layer.cornerRadius = 10
         self.img.clipsToBounds = true
      }
}
