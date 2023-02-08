//
//  AlertController.swift
//  
//
//  Created by Anders Teglgaard on 02/10/2018.
//

import Foundation
import UIKit
import SwiftEntryKit

class AlertController: UIViewController {

    var alert: UIAlertController!

    func notifyUser(title: String, message: String, timeToDissapear: Int) -> Void
    {
        alert = UIAlertController(title: title,
                                  message: message,preferredStyle: UIAlertController.Style.alert)

        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,
            completion: nil)
        // Delay the dismissal by timeToDissapear seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeToDissapear), execute: {
            self.alert.dismiss(animated: true, completion: nil)
        })
    }

    func defaultAlert(title: String, btnTitle: String, message: String, callback: @escaping (String) -> Void)
    {
        alert = UIAlertController(title: title,
                                  message: message,preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: btnTitle, style: .default) { (_) in
            self.alert.dismiss(animated: true, completion: {
                callback(btnTitle)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.alert.dismiss(animated: true, completion: {
                callback("Cancel")
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,
            completion: nil)
    }

    private var displayToastAttributes: EKAttributes = {
        var attributes = EKAttributes()
        attributes = .topFloat
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .visualEffect(style: .init(light: .systemThinMaterialDark, dark: .systemThinMaterialDark))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.displayDuration = 4
        attributes.statusBar = .inferred // INFO: important or else it will try to show the status bar
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        return attributes
    }()

    private var displayLocationAttributes: EKAttributes = {
        var attributes = EKAttributes()
        attributes = .centerFloat
        attributes.windowLevel = .alerts
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = EKAttributes.BackgroundStyle.color(color: EKColor(light: UIColor(white: 100.0/255.0, alpha: 0.3), dark: UIColor(white: 100.0/255.0, alpha: 0.3) ))
        attributes.entryBackground = EKAttributes.BackgroundStyle.color(color: EKColor(light: UIColor.white, dark: UIColor.white))
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.displayDuration = .infinity
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        return attributes
    }()

    private var feedbackWindowAttributes: EKAttributes = {
        var attributes = EKAttributes()
        attributes = .float
        attributes.windowLevel = .normal
        attributes.position = .center
        attributes.displayDuration = .infinity
        attributes.entranceAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .bottom, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0))))
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        attributes.entryBackground = .color(color: EKColor(light: UIColor.darkGray, dark: UIColor.darkGray))
        attributes.screenBackground = .color(color: EKColor(light: UIColor(white: 50.0/255.0, alpha: 0.3), dark: UIColor(white: 50.0/255.0, alpha: 0.3)))
        attributes.border = .value(color: UIColor(white: 0.6, alpha: 1), width: 1)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 3))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.statusBar = .inferred
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 15, screenEdgeResistance: 0))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        return attributes
    }()
    
    private var liveLocationPopUpAttributes: EKAttributes = {
        var attributes = EKAttributes()
        attributes = EKAttributes.centerFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .gradient(
            gradient: .init(
                colors: [EKColor(light: .gradientBackgroundLight,
                                 dark: .gradientBackgroundLight), EKColor(light: .gradientBackgroundDark,
                                                              dark: .gradientBackgroundDark)],
                startPoint: .zero,
                endPoint: CGPoint(x: 1, y: 1)
            )
        )
        attributes.screenBackground = .color(color: EKColor(light: .slateGrey.withAlphaComponent(0.5),
                                                            dark: .slateGrey.withAlphaComponent(0.5)))
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        )
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(
            swipeable: true,
            pullbackAnimation: .jolt
        )
        attributes.roundCorners = .all(radius: 8)
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 0.7, initialVelocity: 0)
            ),
            scale: .init(
                from: 0.7,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.35)
            )
        )
        attributes.positionConstraints.size = .init(
            width: .offset(value: 20),
            height: .intrinsic
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.bounds.width),
            height: .intrinsic
        )
        attributes.statusBar = .hidden
        
        return attributes
    }()
        
    func liveMatchPopup(own_id : String, sender_id: String){
        let name = ""
        // Generate textual content
        let simpleMessage = EKSimpleMessage.createSimpleMessage(
            titleText: "Krown Live Match",
            descriptionText: "Click accept to match instantly",
            titleStyle: .init(font: MainFont.medium.withUI(size: 15), color: .black),
            descriptionStyle: .init(font: MainFont.light.withUI(size: 13), color: .black),
            imageName: "AddImage", imageSize: CGSize(width: 50, height: 50),
            imageContentMode: .scaleAspectFit
        )
        
        // Generate buttons content
        let buttonFont = MainFont.medium.withUI(size: 16)
        
        // Settings Button
        let okButtonLabel = EKProperty.createButtonLabel(
            font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black),
            text: "Match"
        )
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray )) {
            //Match action
            MainController.shared.swipeAction(own_id, action: 1, swipeCardID: sender_id) { result in
            
            }
            SwiftEntryKit.dismiss()
        }
        
        // Disagree Button
        let disagreeButtonLabel = EKProperty.createButtonLabel(
            font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black),
            text: "No thanks"
        )
        
        let disagreeButton = EKProperty.ButtonContent(label: disagreeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray) ) {
            SwiftEntryKit.dismiss()
        }
        
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, disagreeButton, separatorColor: EKColor(light: UIColor.gray, dark: UIColor.gray), expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        // Setup the view itself
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView, using: displayLocationAttributes)
        
    }
    
    
    func showLiveLocationPopup(locationName: String, callback: @escaping (Bool) -> Void) {
        let attributes = liveLocationPopUpAttributes
        let image = UIImage(named: "HandWaving")!.withRenderingMode(.alwaysTemplate)
        let title = "Krown Live Location"
        let description =
        """
        You arrived at a live dating location. \
        See who is single within \(locationName)
        """
        
        let titleColor = EKColor(light: .winterSky,
                                 dark: .winterSky)
        let descriptionColor = EKColor(light: .winterSky,
                                   dark: .winterSky)
        
        let buttonTitleColor = EKColor.white
        
        let buttonBackgroundColor = EKColor(light: .slateGrey,
                                            dark: .slateGrey)
        
        var themeImage: EKPopUpMessage.ThemeImage?
        
            themeImage = EKPopUpMessage.ThemeImage(
                image: EKProperty.ImageContent(
                    image: image,
                    displayMode: .inferred,
                    size: CGSize(width: 60, height: 60),
                    tint: titleColor,
                    contentMode: .scaleAspectFit
                )
            )
        
        let titleLabel = EKProperty.LabelContent(
            text: title,
            style: .init(
                font: MainFont.medium.withUI(size: 24),
                color: titleColor,
                alignment: .center,
                displayMode: .inferred
            ),
            accessibilityIdentifier: "title"
        )
        
        let descriptionLabel = EKProperty.LabelContent(
            text: description,
            style: .init(
                font: MainFont.light.withUI(size: 16),
                color: descriptionColor,
                alignment: .center,
                displayMode: .inferred
            ),
            accessibilityIdentifier: "description"
        )
        let button = EKProperty.ButtonContent(
            label: .init(
                text: "Go!",
                style: .init(
                    font: MainFont.heavy.withUI(size: 16),
                    color: buttonTitleColor,
                    displayMode: .inferred
                )
            ),
            backgroundColor: buttonBackgroundColor,
            highlightedBackgroundColor: buttonTitleColor.with(alpha: 0.05),
            displayMode: .inferred,
            accessibilityIdentifier: "button"
        )
        let message = EKPopUpMessage(
            themeImage: themeImage,
            title: titleLabel,
            description: descriptionLabel,
            button: button) {
                //Go to view from here.
                callback(true)
                SwiftEntryKit.dismiss()
        }
        let contentView = EKPopUpMessageView(with: message)
        SwiftEntryKit.display(entry: contentView, using: attributes)
        
    }

    private func showPopupMessage(attributes: EKAttributes,
                                  title: String,
                                  titleColor: EKColor,
                                  description: String,
                                  descriptionColor: EKColor,
                                  buttonTitleColor: EKColor,
                                  buttonBackgroundColor: EKColor,
                                  image: UIImage? = nil) {
        
        var themeImage: EKPopUpMessage.ThemeImage?
        
        if let image = image {
            themeImage = EKPopUpMessage.ThemeImage(
                image: EKProperty.ImageContent(
                    image: image,
                    displayMode: .inferred,
                    size: CGSize(width: 60, height: 60),
                    tint: titleColor,
                    contentMode: .scaleAspectFit
                )
            )
        }
        let title = EKProperty.LabelContent(
            text: title,
            style: .init(
                font: MainFont.medium.withUI(size: 24),
                color: titleColor,
                alignment: .center,
                displayMode: .inferred
            ),
            accessibilityIdentifier: "title"
        )
        let description = EKProperty.LabelContent(
            text: description,
            style: .init(
                font: MainFont.light.withUI(size: 16),
                color: descriptionColor,
                alignment: .center,
                displayMode: .inferred
            ),
            accessibilityIdentifier: "description"
        )
        let button = EKProperty.ButtonContent(
            label: .init(
                text: "Go!",
                style: .init(
                    font: MainFont.heavy.withUI(size: 16),
                    color: buttonTitleColor,
                    displayMode: .inferred
                )
            ),
            backgroundColor: buttonBackgroundColor,
            highlightedBackgroundColor: buttonTitleColor.with(alpha: 0.05),
            displayMode: .inferred,
            accessibilityIdentifier: "button"
        )
        let message = EKPopUpMessage(
            themeImage: themeImage,
            title: title,
            description: description,
            button: button) {
                //Go to view from here.
                SwiftEntryKit.dismiss()
        }
        let contentView = EKPopUpMessageView(with: message)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    private var displayInfoAttributes: EKAttributes = {
        var attributes = EKAttributes()
        attributes = .centerFloat
        attributes.windowLevel = .alerts
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = EKAttributes.BackgroundStyle.color(color: EKColor(light: .slateGrey.withAlphaComponent(0.5), dark: .slateGrey.withAlphaComponent(0.5)) )
        attributes.entryBackground = EKAttributes.BackgroundStyle.color(color: EKColor(light: UIColor.white, dark: UIColor.white) )
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.displayDuration = .infinity
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        return attributes
    }()

    // TODO: This is a crude solution that will contact the server a lot of times unneccessary.
    func displayToast(for userID: String, with message: String) {

        MainController().getProfile(userID: userID, callback: { (personObject) in
            // Toast is shown
            let title = "\(personObject.name):"
            let desc = message
            let image = "Logo"

            let action = {
                // Go to chat if user wants to interact.
                let chatView = MatchesChatViewVC()
                // TODO: Research why UserFromRosterForJID can be incredible slow. Maybe sync process is going on in background w server
                let jidString = URLHandler.userPreFix + "\(personObject.id)@" + URLHandler.xmpp_domain
                OneChats.addUserToChatList(jidStr: jidString, displayName: personObject.name)
                let user = OneRoster.userFromRosterForJID(jid: URLHandler.userPreFix + personObject.id + URLHandler.xmpp_domainResource)

                chatView.recipientXMPP = user
                chatView.matchObject = MatchObject(id: personObject.id, name: personObject.name, imageArray: personObject.imageArray, lastActiveTime: String(describing: Date()), distance: personObject.distance, interests: [InterestModel]())
                chatView.messageListHistory = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: jidString, senderDisplayName: "")

                if user != nil {// Check to make sure that the user is there
                    let chat = UINavigationController(rootViewController: chatView)
                    chat.modalPresentationStyle = .fullScreen
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = CATransitionType.push
                    transition.subtype = CATransitionSubtype.fromTop
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    UIApplication.shared.windows[0].rootViewController!.view.window!.layer.add(transition, forKey: kCATransition)
                    UIApplication.shared.windows[0].rootViewController!.present(chat, animated: false, completion: nil)

                } else {
                    // Present messages that there is a network error to the server
                }
            }
            self.displayToastAttributes.entryInteraction.customTapActions.append(action)

            self.showTopNotificationMessage(attributes: self.displayToastAttributes, title: title, desc: desc, textColor: EKColor(UIColor.pinkMoment), imageName: image)

            if globalConstant.arrMatchesId.contains(personObject.id){
                NotificationCenter.default.post(name: .reorderChatListVC, object: message)
                NotificationCenter.default.post(name: .refreshChatListVC, object: message)
            }
        })
    }

    // Bumps a notification structured entry
    private func showTopNotificationMessage(attributes: EKAttributes, title: String, desc: String, textColor: EKColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: MainFont.heavy.withUI(size: 18), color: textColor))
        let description = EKProperty.LabelContent(text: desc, style: .init(font: MainFont.medium.withUI(size: 15), color: textColor))
        var image: EKProperty.ImageContent?
        if let imageName = imageName {
            image = .init(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
        }

        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

    func displayLocationAlert() {
        // Generate textual content
        let simpleMessage = EKSimpleMessage.createSimpleMessage(
            titleText: "Location",
            descriptionText: "Krown needs access to your location to find your potential matches. Please go to settings and set location access to 'Always' or 'Allow once'",
            titleStyle: .init(font: MainFont.medium.withUI(size: 15), color: .black),
            descriptionStyle: .init(font: MainFont.light.withUI(size: 13), color: .black),
            imageName: "pin", imageSize: CGSize(width: 50, height: 50),
            imageContentMode: .scaleAspectFit
        )

        // Generate buttons content
        let buttonFont = MainFont.medium.withUI(size: 16)

        // Settings Button
        let okButtonLabel = EKProperty.createButtonLabel(
            font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black),
            text: "Go to settings"
        )
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray )) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    //print("Settings opened: \(success)") // Prints true
                })
            }
            SwiftEntryKit.dismiss()
        }

        // Disagree Button
        let disagreeButtonLabel = EKProperty.createButtonLabel(
            font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black),
            text: "No thanks"
        )

        let disagreeButton = EKProperty.ButtonContent(label: disagreeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray) ) {
            SwiftEntryKit.dismiss()
        }

        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, disagreeButton, separatorColor: EKColor(light: UIColor.gray, dark: UIColor.gray), expandAnimatedly: true)

        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)

        // Setup the view itself
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView, using: displayLocationAttributes)
    }
    func displayLoginLocationAlertWithCompletion(_
                             callback: @escaping (Bool) -> Void) {
        // Generate textual content
        let simpleMessage = EKSimpleMessage.createSimpleMessage(
            titleText: "Location",
            descriptionText: "Krown needs access to your location to find your potential matches. Please go to settings and set location access to 'Always' or 'Allow once'",
            titleStyle: .init(font: MainFont.medium.withUI(size: 15), color: .black),
            descriptionStyle: .init(font: MainFont.light.withUI(size: 13), color: .black),
            imageName: "pin", imageSize: CGSize(width: 50, height: 50),
            imageContentMode: .scaleAspectFit
        )

        // Generate buttons content
        let buttonFont = MainFont.medium.withUI(size: 16)

        // Settings Button
        let okButtonLabel = EKProperty.createButtonLabel(
            font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black),
            text: "Go to settings"
        )
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray )) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    //print("Settings opened: \(success)") // Prints true
                    if success {
                        callback(true)
                    } else {
                        callback(false)
                    }
                })
            }
            //SwiftEntryKit.dismiss()
        }


        // Disagree Button
        let checkButtonLabel = EKProperty.createButtonLabel(
            font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black),
            text: "Check again"
        )

        let checkButton = EKProperty.ButtonContent(label: checkButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray) ) {
            LocationController.shared.checkLocationPermission { status in
                switch status {
                case .notDetermined, .restricted, .denied:
                    break
                case .authorizedAlways, .authorizedWhenInUse, .authorized:
                    SwiftEntryKit.dismiss()
                    callback(true)
                }
            }
            
        }


        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, checkButton, separatorColor: EKColor(light: UIColor.gray, dark: UIColor.gray), expandAnimatedly: true)

        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)

        // Setup the view itself
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView, using: displayLocationAttributes)
    }

    func feedbackWindow() {

        var textFields: [EKProperty.TextFieldContent] = []
        let placeholderStyle = EKProperty.LabelStyle(font: MainFont.light.withUI(size: 14), color: EKColor(light: UIColor(white: 0.8, alpha: 1), dark: UIColor(white: 0.8, alpha: 1)))
        let textStyle = EKProperty.LabelStyle(font: MainFont.light.withUI(size: 14), color: .white)
        let fullNamePlaceholder = EKProperty.LabelContent(text: "Write here...", style: placeholderStyle)
        let fieldContent = EKProperty.TextFieldContent(keyboardType: .asciiCapable, placeholder: fullNamePlaceholder, textStyle: textStyle, isSecure: false, leadingImage: UIImage(named: "receipt"), bottomBorderColor: EKColor(light: UIColor.lightGray, dark: UIColor.lightGray))
            textFields.append(fieldContent)

        let title = EKProperty.LabelContent(text: "Fill in your feedback details", style: EKProperty.LabelStyle(font: MainFont.light.withUI(size: 16), color: .white, alignment: .center))

        let button = EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Send Feedback", style: EKProperty.LabelStyle(font: MainFont.light.withUI(size: 16), color: .white)), backgroundColor: EKColor(light: UIColor.lightGray, dark: UIColor.lightGray), highlightedBackgroundColor: EKColor(light: UIColor.white.withAlphaComponent(0.8), dark: UIColor.white.withAlphaComponent(0.8))) {
            let message = "The user: \(UserDefaults.standard.object(forKey: WebKeyhandler.User.userID)!) has written this feedback: \(fieldContent.textContent)"
            let mainController = MainController()
            mainController.sendEmail(to: "info@krownapp.com", message: message, callback: { (_) in
            })
            SwiftEntryKit.dismiss()
        }

        let contentView = EKFormMessageView(with: title, textFieldsContent: textFields, buttonContent: button)
        SwiftEntryKit.display(entry: contentView, using: feedbackWindowAttributes)
    }

    func displayInfo(title: String, message: String) {
        // Generate textual content

        let simpleMessage = EKSimpleMessage.createSimpleMessage(
            titleText: title,
            descriptionText: message,
            titleStyle: .init(font: MainFont.medium.withUI(size: 15), color: .  black, alignment: .center),
            descriptionStyle: .init(font: MainFont.light.withUI(size: 13), color: .black, alignment: .center),
            imageName: "help",
            imageSize: CGSize(width: 50, height: 50),
            imageContentMode: .scaleAspectFit
        )

        // Generate buttons content
        let buttonFont = MainFont.medium.withUI(size: 16)

        // Disagree Button
        let okButtonLabel = EKProperty.createButtonLabel(font: buttonFont, color: EKColor(light: UIColor.black, dark: UIColor.black), text: "OK")
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: EKColor(light: UIColor.gray, dark: UIColor.gray)) {
            SwiftEntryKit.dismiss()
        }

        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, separatorColor: EKColor(light: UIColor.gray, dark: UIColor.gray), expandAnimatedly: true)

        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)

        // Setup the view itself
        let contentView = EKAlertMessageView(with: alertMessage)

        SwiftEntryKit.display(entry: contentView, using: displayInfoAttributes)
    }
}
