//
//  ChatTblCell.swift
//  Krown
//
//  Created by macOS on 29/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import SDWebImage

class ChatTblCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lbl_user_name: UILabel!
    @IBOutlet weak var lbl_msg: UILabel!
    @IBOutlet weak var img_online: UIImageView!
    @IBOutlet weak var badge: UILabel!
    var matchObject: MatchObject!
    var looperFrontImage: Looper? {
        didSet {
            configLooperFrontImage()
        }
    }
    func configLooperFrontImage() {
        looperFrontImage?.start(in: imgUser.layer)
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

    override func awakeFromNib() {
        super.awakeFromNib()
        imgUser.layer.masksToBounds = false
        imgUser.layer.cornerRadius = imgUser.frame.width/2
        imgUser.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        looperFrontImage?.stop()
        lbl_msg.text = ""
        imgUser.image = nil
        badge.text = ""
        badge.backgroundColor = .clear
    }

}
