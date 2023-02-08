//
//  SwiftEntryKitExtensions.swift
//  Krown
//
//  Created by KrownUnity on 05/07/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftEntryKit

extension EKSimpleMessage {

    static func createSimpleMessage(titleText: String, descriptionText: String, titleStyle: EKProperty.LabelStyle, descriptionStyle: EKProperty.LabelStyle, imageName: String, imageSize: CGSize, imageContentMode: UIView.ContentMode) -> Self {
        let title = EKProperty.LabelContent(text: titleText, style: titleStyle)
        let description = EKProperty.LabelContent(text: descriptionText, style: descriptionStyle)
        let image = EKProperty.ImageContent(imageName: imageName, size: imageSize, contentMode: imageContentMode)
        return Self.init(image: image, title: title, description: description)
    }
}

extension EKProperty {

    static func createButtonLabel(font: UIFont, color: EKColor, text: String) -> Self.LabelContent {
        let buttonStyle = Self.LabelStyle(font: font, color: color)
        let buttonLabel = Self.LabelContent(text: text, style: buttonStyle)
        return buttonLabel
    }

}
