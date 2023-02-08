//
//  UIViewExtentions.swift
//  Krown
//
//  Created by KrownUnity on 19/10/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

import Foundation
import SwiftUI

extension UIView{
    
    /**
     show a uiview from  bottom to top with animation and duration
     
     - parameter secondaryView: display the uiview behind the main view
     - parameter bottomConstraint: bottom constraint of uiview to animate from bottom to top
     */
    func animShow(secondaryView : UIView, bottomConstraint:  NSLayoutConstraint ){
        

        secondaryView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.center.y -= self.bounds.height
            
            bottomConstraint.constant = 50
            
                        self.alpha = 1.0
                        secondaryView.alpha = 0.0
                        self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    /**
     hide a uiview from  top to bottom with animation and duration
     
     - parameter secondaryView: display the uiview behind the main view
     - parameter bottomConstraint: bottom constraint of uiview to animate from top to bottom
     */
    func animHide(secondaryView : UIView, bottomConstraint:  NSLayoutConstraint ){
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y += self.bounds.height
            bottomConstraint.constant = 0
            self.alpha = 0.0
                        secondaryView.alpha = 0.0
                        self.layoutIfNeeded()

        },  completion: {(_ completed: Bool) -> Void in
                self.isHidden = true
                secondaryView.isHidden = true
            })
    }
}

extension UIView {

    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    func blurImageDark() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
    }

    func blurImageLight() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        self.clipsToBounds = true
    }

   /* Fade out a view with a duration*/

    func fadeIn(duration: TimeInterval = 0.5) {
         UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
             self.isHidden = false
         })
     }

    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
            self.isHidden = true
        })
      }

    /**
    - Make whole view round
     */
    func makeRoundView()
    {
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.masksToBounds = true
    }
    
}

 // MARK: - Doubt
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


//MARK: - swiftui view
extension View {
    func figmaDropShadow(color: Color = .black, alpha: Double = 0.25, x: CGFloat = 0, y: CGFloat = 1, blur: CGFloat = 4) -> some View {
        self
            .shadow(color: color.opacity(alpha), radius: blur/2, x: x, y: y)
        
    }
}

extension UITableView {
    
    func register<T: UITableViewCell>(_: T.Type, indexPath: IndexPath) -> T {
        self.register(UINib(nibName: String(describing: T.self), bundle: .main), forCellReuseIdentifier: String(describing: T.self))
        let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
        return cell
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type, indexPath: IndexPath) -> T {
        self.register(UINib(nibName: String(describing: T.self), bundle: Bundle.main), forCellWithReuseIdentifier: String(describing: T.self))
        let cell = self.dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
        return cell
    }
}



extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

//MARK: - StoryBoard Reference
extension UIStoryboard {
    
    class func controller  <T: UIViewController> (storyboardName : String = "Home") -> T {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: T.className) as! T
    }
}

//MARK: - NSObject
extension NSObject {
    class var className: String {
        return String(describing: self.self)
    }
}
