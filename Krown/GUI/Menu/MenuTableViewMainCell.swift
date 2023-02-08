//
//  TableViewCell.swift
//  Krown
//
//  Created by KrownUnity on 04/10/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
import Alamofire

class MenuTableViewMainCell: UITableViewCell {

    @IBOutlet weak var profilPic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var scopeBtn: UIButton!
    @IBOutlet weak var prefBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var suggestedEventsLbl: UILabel!
    var looper: Looper? {
        didSet {
            configLooper()
        }
    }

    override func awakeFromNib() {

        super.awakeFromNib()
        // Initialization code

        let placeholderImage = UIImage(named: "man.jpg")!
        // BUG: The line below force unwraps a key that is nil in userdefaults (maybe because of a crash before in login) Tested and after a perfect login sequence the problem did not persist. Consider opportunities to log a user out again.
        if let profilePictures = UserDefaults.standard.object(forKey: WebKeyhandler.User.profilePic) {
            if let profilePicture = (profilePictures as! [String]).first {
                let url = URL(string: profilePicture)!
                if url.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                    looper = PlayerLooper(videoURL: url, loopCount: -1)
                } else {
                    //Add authentication header
                    var imageUrlRequest = URLRequest(url: url)
                    var headers: HTTPHeaders
                    if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                        headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
                    } else {
                        headers = [.authorization(bearerToken: "ForceRefresh"),]
                    }
                    imageUrlRequest.headers = headers
                    profilPic.af.setImage(withURLRequest: imageUrlRequest, placeholderImage: placeholderImage)
                }
            }

        }
        profilPic.layer.masksToBounds = false
        profilPic.layer.cornerRadius = profilPic.frame.width/2
        profilPic.clipsToBounds = true

        let firstname: String = UserDefaults.standard.object(forKey: WebKeyhandler.User.firstName) as! String

        name.text = firstname

    }
    func configLooper() {
        looper?.start(in: profilPic.layer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        looper?.stop()
    }

}
