//
//  BottomChat.swift
//  Krown
//
//  Created by macOS on 05/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class BottomChat: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewTxtChat: UIView! {
        didSet {
            viewTxtChat.layer.cornerRadius = 22.5
            viewTxtChat.layer.borderWidth = 1
            viewTxtChat.layer.borderColor = UIColor.slateGrey.cgColor
            viewTxtChat.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var btn_attachment: UIButton!
    @IBOutlet weak var btn_camera: UIButton!
    @IBOutlet weak var btn_gallery: UIButton!
    @IBOutlet weak var btn_location: UIButton!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var txtChatHeight: NSLayoutConstraint!
    @IBOutlet weak var txtChat: MultilineTextField! {
        didSet {
            txtChat.font = UIFont(name: "Avenir-Medium", size: 16)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("BottomChat", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
