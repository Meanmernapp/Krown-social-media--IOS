//
//  Font.swift
//  Krown
//
//  Created by Anders Teglgaard on 01/10/2018.
//  Copyright © 2018 KrownUnity. All rights reserved.
//

import UIKit
import SwiftUI

typealias MainFont = AppFont.Avenir

enum AppFont {
    enum Avenir: String {
        case light = "Light"
        case medium = "Medium"
        case heavy = "Heavy"
        
        func withUI(size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir-\(rawValue)", size: size)!
        }
        func with(size: CGFloat) -> Font {
            return Font.custom("Avenir-\(rawValue)", fixedSize: size)
        }
    }
}
