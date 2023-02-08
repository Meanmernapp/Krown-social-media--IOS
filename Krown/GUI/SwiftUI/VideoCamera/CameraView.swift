//
//  CameraView.swift
//  Krown
//
//  Created by Ivan Kodrnja on 16.08.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI
import AVKit
import AVFoundation

struct CameraView: View {
    @EnvironmentObject var cameraModel: CameraViewModel
    var body: some View{
        
        // if showPreview is false
        if !cameraModel.showPreview {
            GeometryReader{proxy in
                let size = proxy.size
                // we wait for capture session to be prepared in CAmeraViewModel
                if cameraModel.captureSessionCommitted {
                    CameraPreview(size: size)
                        .environmentObject(cameraModel)
                        .rotation3DEffect(.degrees(cameraModel.rotationDegree), axis: (x: 0, y: 1, z: 0))
                }
            }
        
        } else {
            // shows video preview
            GeometryReader{proxy in
                let size = proxy.size
                
                CustomLoopingPlayerView(size: size)
                    .environmentObject(cameraModel)
            }
            
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    
    @EnvironmentObject var cameraModel : CameraViewModel
    var size: CGSize
    
    func makeUIView(context: Context) ->  UIView {
     
        let view = UIView()
        
        if cameraModel.preview == nil {
            cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
            cameraModel.preview.frame.size = size
            cameraModel.preview.videoGravity = .resizeAspectFill
            
            if cameraModel.preview.connection!.isVideoMirroringSupported {
                
                cameraModel.preview.connection!.automaticallyAdjustsVideoMirroring = false
                cameraModel.preview.connection?.isVideoMirrored = true
            }
            
            view.layer.addSublayer(cameraModel.preview)
        } else {
    
            cameraModel.preview.session = cameraModel.session
            
            if cameraModel.preview.connection!.isVideoMirroringSupported {
                
                cameraModel.preview.connection!.automaticallyAdjustsVideoMirroring = false
                cameraModel.preview.connection?.isVideoMirrored = true
            }
            view.layer.addSublayer(cameraModel.preview)
        }
        
        

        DispatchQueue.main.async {
            cameraModel.session.startRunning()
            
        }
        

        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}


struct CustomLoopingPlayerView: UIViewRepresentable {
    
    @EnvironmentObject var cameraModel : CameraViewModel
    var size: CGSize
    
    func makeUIView(context: Context) ->  UIView {
     
        let view = UIView()

        // Load the resource
        let fileUrl = cameraModel.previewURL!
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)

        // Setup the player
        
        cameraModel.player = AVQueuePlayer()
        cameraModel.playerLayer.player = cameraModel.player
        cameraModel.playerLayer.frame.size = size
        cameraModel.playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraModel.playerLayer)
         
        // Create a new player looper with the queue player and template item
        cameraModel.playerLooper = AVPlayerLooper(player: cameraModel.player!, templateItem: item)

        
        DispatchQueue.main.async {
            // Start the movie
            cameraModel.player!.play()

        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
