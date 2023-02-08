//
//  MyProfileViewController.swift
//  Krown
//
//  Created by HaiDer's Macbook Pro on 24/01/2023.
//  Copyright © 2023 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage

struct MyProfileStruct {
    var title : String?
    var image : UIImage?
}
class MyProfileViewController: UIViewController {
    
    
    //MARK: - IBOutlets

    @IBOutlet weak var nameAgeLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImgView: UIImageView!
    
    
    //MARK: - Variables
    
    var dataArray : [MyProfileStruct] = [
        MyProfileStruct(title: "My Discovery Filters", image: UIImage(named: "SlidersHorizontal")!),
        MyProfileStruct(title: "My Settings", image: UIImage(named: "settings")!),
        MyProfileStruct(title: "Feedback", image: UIImage(named: "UserSpeaking")!)
    ]
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.download()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: - IBAction
    
    
    @IBAction func editAction(_ sender: Any) {
        let swiftUIView = ProfileView()
        let viewCtrl = UIHostingController(rootView: swiftUIView)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(viewCtrl, animated: true)
    }
    
    
    //MARK: - Functions
    
    func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImgView.isUserInteractionEnabled = true
        profileImgView.addGestureRecognizer(tapGestureRecognizer)
        self.nameAgeLbl.text = "\(globalConstant.personObject.name), \(globalConstant.personObject.age)"
        self.nameAgeLbl.font = MainFont.medium.withUI(size: 20)
        self.nameAgeLbl.textColor = UIColor.slateGrey
        self.profileImgView.setRounded()
//        self.view.layoutIfNeeded()
    }
    
    func download() {
        self.profileImgView.sd_setImage(with: URL(string: globalConstant.personObject.imageArray.first ?? ""), placeholderImage: UIImage(named: "man.jpg"))
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let _ = tapGestureRecognizer.view as! UIImageView
        let vc : ProfilePreviewVC = UIStoryboard.controller(storyboardName: "Profile")
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.register(MyProfileSegementsTableViewCell.self, indexPath: indexPath)
        cell.config(data: dataArray[indexPath.row])
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let vc : ScopeVC = UIStoryboard.controller(storyboardName: "Profile")
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc : SettingsVC = UIStoryboard.controller(storyboardName: "Profile")
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc : FeedbackVC = UIStoryboard.controller(storyboardName: "Profile")
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
}



extension UIImageView {

   func setRounded() {
      let radius = CGRectGetWidth(self.frame) / 2
      self.layer.cornerRadius = radius
      self.layer.masksToBounds = true
   }
}

class RoundedImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        assert(bounds.height == bounds.width, "The aspect ratio isn't 1/1. You can never round this image view!")

        layer.cornerRadius = bounds.height / 2
    }
}
