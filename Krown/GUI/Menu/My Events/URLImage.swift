//
//  URLImage.swift
//  Krown
//
//  Created by macOS on 22/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct URLImage: View {
    
    let url: String
    let placeholder: String
    
    @ObservedObject var videoImageLoader = VideoImageLoader()
    
    init(url: String, placeholder: String = "photo") {
        self.url = url
        self.placeholder = placeholder
        self.videoImageLoader.downloadImage(url: self.url)
    }

    var body: some View {
        if let data = self.videoImageLoader.downloadedData {
            return Image(uiImage: UIImage(data: data)!).resizable().aspectRatio(contentMode: .fill)
        } else {
            return Image(systemName: "photo").resizable().aspectRatio(contentMode: .fill)
        }
    }
    
}
