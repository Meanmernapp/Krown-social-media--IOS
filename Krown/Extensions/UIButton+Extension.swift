//
//  UIButton+Extension.swift
//  Krown
//
//  Created by Potenza on 23/06/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
import UIKit


extension UIButton
{
    
    func makeButtonRound()
    {
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.masksToBounds = true
    }
    
}
extension UIButton
{

  func alignTextUnderImage(spacing: CGFloat = 0.0)
  {
      if let image = self.imageView?.image
      {
          let imageSize: CGSize = image.size
          self.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -imageSize.width, bottom: -(imageSize.height), right: 0.0)
          let labelString = NSString(string: self.titleLabel?.text ?? "      ")
          let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: self.titleLabel?.font ?? MainFont.light.withUI(size: 14) ])
          self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
      }
  }
}
