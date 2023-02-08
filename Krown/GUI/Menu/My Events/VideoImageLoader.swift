//
//  VideoImageLoader.swift
//  Krown
//
//  Created by macOS on 22/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//#imageLiteral(resourceName: "simulator_screenshot_7A45C815-A0CE-400A-9734-4A68768F68E9.png")

import Foundation
import AVKit

class VideoImageLoader: ObservableObject {
    
    @Published var downloadedData: Data?
    
    func downloadImage(url: String) {
        
        guard let imageURL = URL(string: url) else {
            fatalError("ImageURL is not correct!")
        }
        DispatchQueue.global().async { //1
//            let asset = AVAsset(url: imageURL) //2
            
            //Add authentication header
            var header : String
            if UserDefaults.standard.object(forKey: "app_auth_token") != nil {
                header = UserDefaults.standard.object(forKey: "app_auth_token")! as! String
            } else {
                header = "ForceRefresh"
            }
            let headers: [AnyHashable : Any] = [
                "content-type": "application/json",
                "authorization": "Bearer \(header)"
            ]
            let asset: AVURLAsset = AVURLAsset.init(url: imageURL, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
          
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    self.downloadedData = thumbImage.jpegData(compressionQuality: 1)
                }
            } catch {
                //print(error.localizedDescription) //10
            }
        }
    }
    
    
}
