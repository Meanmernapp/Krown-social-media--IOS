//
//  UIViewController+Extension.swift
//  Krown
//
//  Created by Apple on 19/06/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {

    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */

    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
