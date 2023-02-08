//
//  DiscoverPeopleVideoPlayer.swift
//  Krown
//
//  Created by Ivan Kodrnja on 15.10.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
// https://www.hackingwithswift.com/forums/swift/avplayer-streaming-from/6431

import AVKit
import Cache

class DiscoverPeopleVideoPlayer {
    
    static let shared = DiscoverPeopleVideoPlayer()

    private var player: AVPlayer!
    let diskConfig = DiskConfig(name: "DiscoverPeopleDiskCache", expiry: .never)
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

    lazy var storage: Cache.Storage<String, Data>? = {
            return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
        }()

    /// Plays a video either from the network if it's not cached or from the cache.
    func play(with url: URL) -> AVPlayer {
        let playerItem: CachingPlayerItem
        do {
            let result = try storage!.entry(forKey: url.absoluteString)
            // The video is cached.
            playerItem = CachingPlayerItem(data: result.object, mimeType: "video/mp4", fileExtension: "mp4")
        } catch {
            // The video is not cached.
            playerItem = CachingPlayerItem(url: url)
        }

        playerItem.delegate = self
        self.player = AVPlayer(playerItem: playerItem)
        self.player.automaticallyWaitsToMinimizeStalling = false
        // enables looping
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { notification in
            self.player.seek(to: CMTime.zero)
            self.player.play()
            }
        
        // Remove expired objects
        try? storage?.removeExpiredObjects()
        
        return self.player
    }

}

// MARK: - CachingPlayerItemDelegate
extension DiscoverPeopleVideoPlayer: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // Video is downloaded. Saving it to the cache asynchronously.
        storage?.async.setObject(data, forKey: playerItem.url.absoluteString, completion: { _ in })
    }
}
