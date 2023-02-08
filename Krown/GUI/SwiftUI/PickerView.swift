//
//  PickerView.swift
//  Krown
//
//  Created by Ivan Kodrnja on 05.01.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
// https://designcode.io/swiftui-advanced-handbook-imagepicker

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var profileInfoEdited : Bool
    @EnvironmentObject var webServiceController: WebServiceController

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.webServiceController.resizeUploadImage(originalImage: image)
                parent.profileInfoEdited = true
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}
