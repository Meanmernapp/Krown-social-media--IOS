//
//  ChatImgCollCell.swift
//  Krown
//
//  Created by macOS on 29/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import SDWebImage

class ChatImgCollCell: UICollectionViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgUser.layer.cornerRadius = 35
        imgUser.layer.borderColor = UIColor.royalPurple.cgColor
        imgUser.layer.borderWidth = 2
        imgUser.layer.masksToBounds = true
        // Initialization code
    }
    var matchObject: MatchObject!

    var looperFrontImage: Looper? {
        didSet {
            configLooperFrontImage()
        }
    }
    func configLooperFrontImage() {
        looperFrontImage?.start(in: imgUser.layer)
    }
    override func prepareForReuse() {
        looperFrontImage?.stop()
        imgUser.image = nil
    }

    func loadImage(_ urlImg : URL) {
        imgUser.sd_cancelCurrentImageLoad()
        if let image = SDImageCache.shared.imageFromDiskCache(forKey: urlImg.absoluteString) {
            imgUser.image = image
        } else {
            guard let thumbnailImage = UIImage(named: "man") else {
                imgUser.image = nil
                return
            }
            
            imgUser.sd_imageIndicator?.startAnimatingIndicator()
            imgUser.sd_setImage(with: urlImg, placeholderImage: thumbnailImage) { (image, err, type, url) in
                if let image = SDImageCache.shared.imageFromDiskCache(forKey: urlImg.absoluteString) {
                    self.imgUser.image = image
                } else {
                    self.imgUser.image = thumbnailImage
                }
                self.imgUser.sd_imageIndicator?.stopAnimatingIndicator()
            }
        }
    }
}
