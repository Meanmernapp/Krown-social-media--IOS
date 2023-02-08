//
//  MyProfileSegementsTableViewCell.swift
//  Krown
//
//  Created by HaiDer's Macbook Pro on 24/01/2023.
//  Copyright © 2023 KrownUnity. All rights reserved.
//

import UIKit

class MyProfileSegementsTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(data:MyProfileStruct) {
        self.imgView.image = data.image
        self.titleLbl.text = data.title
    }
    
}
