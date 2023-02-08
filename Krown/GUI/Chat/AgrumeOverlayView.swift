//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import Agrume
import UIKit

protocol OverlayViewDelegate: AnyObject {
  func overlayView(_ overlayView: AgrumeCustomOverlayView, didSelectAction action: String)
}

/// Example custom image overlay
final class AgrumeCustomOverlayView: AgrumeOverlayView {
    var image = UIImage()

    lazy var toolbar: UIToolbar = {
      let toolbar = UIToolbar()
      toolbar.translatesAutoresizingMaskIntoConstraints = false

        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(selectShare))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(selectSave))
        // tag will be used to uniquely track save button which will be disabeld if the image is already saved
        save.tag = 1234
        save.isEnabled = true
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(selectDelete))
        toolbar.setItems([share, flexSpace, save, flexSpace, delete], animated: false)

      return toolbar
    }()

  lazy var navigationBar: UINavigationBar = {
    let navigationBar = UINavigationBar()
    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    navigationBar.pushItem(UINavigationItem(title: "Image"), animated: false)

    return navigationBar
  }()

  var portableSafeLayoutGuide: UILayoutGuide {
    if #available(iOS 11.0, *) {
      return safeAreaLayoutGuide
    }
    return layoutMarginsGuide
  }

  weak var delegate: OverlayViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {

        addSubview(toolbar)

        NSLayoutConstraint.activate([
          toolbar.bottomAnchor.constraint(equalTo: portableSafeLayoutGuide.bottomAnchor),
          toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
          toolbar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

    addSubview(navigationBar)
    navigationBar.delegate = self

    NSLayoutConstraint.activate([
        navigationBar.topAnchor.constraint(equalTo: portableSafeLayoutGuide.topAnchor),
      navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])

  }

    @objc
    private func selectShare() {

      delegate?.overlayView(self, didSelectAction: "share")

    }

  @objc
  private func selectSave() {
    delegate?.overlayView(self, didSelectAction: "save")

  }

  @objc
  private func selectDelete() {
    delegate?.overlayView(self, didSelectAction: "delete")

  }

}

// conforming to UINavigationBarDelegate delegate  protocol in order to expand navigation bar over status bar as in https://upte.ch/blog/extend-uinavigation-bar-behind-status-bar/
extension AgrumeCustomOverlayView: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        guard self.navigationBar == bar as? UINavigationBar else {
            return bar.barPosition
        }
        return UIBarPosition.topAttached
    }
}
