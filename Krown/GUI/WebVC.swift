//
//  WebVC.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    var url: String = ""
    var headline: String = ""

    @IBAction func backBtn(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = headline
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL!)
        webView.load(request)
    }

}
