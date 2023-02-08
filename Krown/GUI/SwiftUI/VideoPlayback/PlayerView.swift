//
//  PlayerView.swift
//  Krown
//
//  Created by Ivan Kodrnja on 11.09.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//  inspired by https://schwiftyui.com/swiftui/playing-videos-on-a-loop-in-swiftui/

import SwiftUI
import AVKit
import AVFoundation
import UIKit
import Cache

class CacheAdapter {
    
    static let shared = CacheAdapter()
    
    let diskConfig = DiskConfig(name: "DiskCache", expiry: .never)
    let memoryConfig = MemoryConfig(expiry: .seconds(24 * 60 * 60), countLimit: 10, totalCostLimit: 10)

    lazy var storage: Cache.Storage<String, Data>? = {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    var cacheAdapter = CacheAdapter.shared

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var videoURL: URL
    
    

    init(frame: CGRect, videoURL: URL) {
        self.videoURL = videoURL
        super.init(frame: frame)

        setupVideo(videoURL: videoURL)
    }
    
    

    func setupVideo(videoURL: URL) {
        
        let playerItem: CachingPlayerItem
        do {
            let result = try cacheAdapter.storage!.entry(forKey: videoURL.absoluteString)
            // The video is cached.
            playerItem = CachingPlayerItem(data: result.object, mimeType: "video/mp4", fileExtension: "mp4")
        } catch {
            // The video is not cached.
            playerItem = CachingPlayerItem(url: videoURL)
        }
        

        // Setup the player
     
        playerItem.delegate = self
        let player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        
        layer.addSublayer(playerLayer)

        // Setup looping
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        // Start the movie
        player.play()
        
        // Remove expired objects
        try? cacheAdapter.storage?.removeExpiredObjects()
    }

    @objc
    func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - CachingPlayerItemDelegate
extension PlayerUIView: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // Video is downloaded. Saving it to the cache asynchronously.
        cacheAdapter.storage?.async.setObject(data, forKey: playerItem.url.absoluteString, completion: { _ in })
    }
}

struct PlayerView: UIViewRepresentable {
    let videoURL: URL

    func updateUIView(_ uiView: PlayerUIView, context: Context) {

        uiView.setupVideo(videoURL: videoURL)
    }

    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(frame: .zero, videoURL: videoURL)
    }
}
