//
//  WaveTblCell.swift
//  Krown
//
//  Created by macOS on 09/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage

class WaveTblCell: UITableViewCell {

    @IBOutlet weak var imgUser1: UIImageView! {
        didSet {
            imgUser1.layer.cornerRadius = 35
            imgUser1.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var imgUser2: UIImageView!{
        didSet {
            imgUser2.layer.cornerRadius = 35
            imgUser2.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var imgUser3: UIImageView!{
        didSet {
            imgUser3.layer.cornerRadius = 35
            imgUser3.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var viewUserPlus: UIView!{
        didSet {
            viewUserPlus.layer.cornerRadius = 35
            viewUserPlus.layer.masksToBounds = true
            viewUserPlus.layer.borderColor = UIColor.royalPurple.cgColor
            viewUserPlus.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var waveLeading: NSLayoutConstraint!//55,33,4
    @IBOutlet weak var txtLeading: NSLayoutConstraint!//88,66,37
    @IBOutlet weak var lbl_count: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        let asset = AVURLAsset(url: url)

        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            //print("Error: \(error)")
            return nil
        }

        return UIImage(cgImage: thumbnailImageRef)
    }

    func setData(_ waveArr : [MatchObject]) {
        viewUserPlus.isHidden = true
        imgUser3.isHidden = true
        if waveArr.count > 3 {
            // 2 image + count
            waveLeading.constant = 55
            txtLeading.constant = 88
            viewUserPlus.isHidden = false
            lbl_count.text = "\(waveArr.count - 2)+"
            setImgUser1(waveArr[0])
            setImgUser2(waveArr[1])
        } else if waveArr.count > 2 {
            // 3 images
            waveLeading.constant = 55
            txtLeading.constant = 88
            imgUser3.isHidden = false
            setImgUser1(waveArr[0])
            setImgUser2(waveArr[1])
            setImgUser3(waveArr[2])
        } else if waveArr.count > 1 {
            // 2 images
            waveLeading.constant = 33
            txtLeading.constant = 66
            setImgUser1(waveArr[0])
            setImgUser2(waveArr[1])
        } else {
            // 1 image
            waveLeading.constant = 4
            txtLeading.constant = 37
            imgUser2.isHidden = true
            setImgUser1(waveArr[0])
        }
    }
    
    func setImgUser1(_ match : MatchObject) {
        var path = ""
            if let resourcePath = Bundle.main.resourcePath {
              let imgName = "man"
              path = resourcePath + "/" + imgName
            }
        var imageUrl = URL(fileURLWithPath: path)

        if match.imageArray.count > 0 {
            imageUrl = URL(string: match.imageArray[0])!
        }
        if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
            DispatchQueue.global(qos: .background).async {
                let imageFrameFromWindow = self.imageFromVideo(url: imageUrl, at: 1)
                DispatchQueue.main.async { [self] in
                    UIView.transition(with: imgUser1,
                                      duration: 0.2,
                                      options: .transitionCrossDissolve,
                                      animations: { imgUser1.image = imageFrameFromWindow },
                                      completion: nil)
                    
                }
            }
        } else {
            let placeholderImage = UIImage(named: "man")!
            imgUser1.sd_setImage(with: imageUrl, placeholderImage: placeholderImage, options: .retryFailed, context: nil)
        }
    }
    func setImgUser2(_ match : MatchObject) {
        var path = ""
            if let resourcePath = Bundle.main.resourcePath {
              let imgName = "man"
              path = resourcePath + "/" + imgName
            }
        var imageUrl = URL(fileURLWithPath: path)

        if match.imageArray.count > 0 {
            imageUrl = URL(string: match.imageArray[0])!
        }
        if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
            DispatchQueue.global(qos: .background).async {
                let imageFrameFromWindow = self.imageFromVideo(url: imageUrl, at: 1)
                DispatchQueue.main.async { [self] in
                    UIView.transition(with: imgUser2,
                                      duration: 0.2,
                                      options: .transitionCrossDissolve,
                                      animations: { imgUser2.image = imageFrameFromWindow },
                                      completion: nil)
                    
                }
            }
        } else {
            let placeholderImage = UIImage(named: "man")!
            imgUser2.sd_setImage(with: imageUrl, placeholderImage: placeholderImage, options: .retryFailed, context: nil)
        }
    }
    func setImgUser3(_ match : MatchObject) {
        var path = ""
            if let resourcePath = Bundle.main.resourcePath {
              let imgName = "man"
              path = resourcePath + "/" + imgName
            }
        var imageUrl = URL(fileURLWithPath: path)

        if match.imageArray.count > 0 {
            imageUrl = URL(string: match.imageArray[0])!
        }
        if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
            DispatchQueue.global(qos: .background).async {
                let imageFrameFromWindow = self.imageFromVideo(url: imageUrl, at: 1)
                DispatchQueue.main.async { [self] in
                    UIView.transition(with: imgUser3,
                                      duration: 0.2,
                                      options: .transitionCrossDissolve,
                                      animations: { imgUser3.image = imageFrameFromWindow },
                                      completion: nil)
                    
                }
            }
        } else {
            let placeholderImage = UIImage(named: "man")!
            imgUser3.sd_setImage(with: imageUrl, placeholderImage: placeholderImage, options: .retryFailed, context: nil)
        }
    }

}
