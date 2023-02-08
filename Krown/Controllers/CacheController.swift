//
//  CacheController.swift
//  Krown
//
//  Created by Ivan Kodrnja on 01.11.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import Foundation
import SDWebImage

class CacheController {
    
    static var shared = CacheController()
    
    func removeSwipedPersonsCachedProfileImages(imageURLArray: [URL]){
        
        for imageUrl in imageURLArray{
            // check for mp4 videos
            if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {
                // remove videos from cache
                try? DiscoverPeopleVideoPlayer.shared.storage?.removeObject(forKey: imageUrl.absoluteString)
            } else {
                // original image
                var imageUrlsToCheck = [URL]()
                imageUrlsToCheck.append(imageUrl)
                // thumbnail image
                var thumbnailImageUrl = imageUrl
                let thumbnailImageUrlLastPathComponent = WebKeyhandler.imageHandling.thumbnailProfileImage + thumbnailImageUrl.lastPathComponent
                thumbnailImageUrl.deleteLastPathComponent()
                thumbnailImageUrl.appendPathComponent(thumbnailImageUrlLastPathComponent)
                imageUrlsToCheck.append(thumbnailImageUrl)
                // small image
                var smallImageUrl = imageUrl
                let smallImageUrlLastPathComponent = WebKeyhandler.imageHandling.smallProfileImage + smallImageUrl.lastPathComponent
                smallImageUrl.deleteLastPathComponent()
                smallImageUrl.appendPathComponent(smallImageUrlLastPathComponent)
                imageUrlsToCheck.append(smallImageUrl)
                // medium image
                var mediumImageUrl = imageUrl
                let mediumImageUrlLastPathComponent = WebKeyhandler.imageHandling.mediumProfileImage + mediumImageUrl.lastPathComponent
                mediumImageUrl.deleteLastPathComponent()
                mediumImageUrl.appendPathComponent(mediumImageUrlLastPathComponent)
                imageUrlsToCheck.append(mediumImageUrl)
                
                // we will check for every image size if it exists in cache and remove it
                for imageUrlToCheck in imageUrlsToCheck {
                            SDImageCache.shared.removeImage(forKey: imageUrlToCheck.absoluteString)
                }
            }
        }
    }
    
}
