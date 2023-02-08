//
//  CameraViewModel.swift
//  Krown
//
//  Created by Ivan Kodrnja on 16.08.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//  

import SwiftUI
import AVFoundation

// MARK: Camera View Model
class CameraViewModel: NSObject,ObservableObject,AVCaptureFileOutputRecordingDelegate{
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCaptureMovieFileOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var captureSessionCommitted = false
    @Published var isFlipButtonPressed = false
    
    // MARK: Video Recorder Properties
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    @Published var previewURL: URL?
    @Published var showPreview: Bool = false
    
    var uploadVideoURL: URL?

    // circular progress bar
    @Published var circleProgress: CGFloat = 0.0
    @Published var maxDuration: CGFloat = 6.0
    
    // toggle record button
    @Published var isRecordButtonDisabled = false
    
    // toggle retake and choos buttons
    @Published var showReatkeChooseButton = false
    
    // looping player
    @Published var playerLayer = AVPlayerLayer()
    @Published var playerLooper: AVPlayerLooper?
    @Published var player: AVQueuePlayer?
    
    @Published var rotationDegree: Double = 0.0
    
    var videoInput: AVCaptureDeviceInput!
    // MARK: Device Configuration Properties
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    
    func checkPermission(){
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                
                if status{
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp(){
        
        do{
            self.session.beginConfiguration()
            let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            self.videoInput = try AVCaptureDeviceInput(device: cameraDevice!)

            if self.session.canAddInput(self.videoInput) {
                self.session.addInput(self.videoInput)
            }

            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
                
                if let videoConnection = self.output.connection(with: .video){
                    if self.videoInput.device.position == .front {
                    
                        videoConnection.isVideoMirrored = true
                    }
                 }
                
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.captureSessionCommitted = true
            }
            
        }
        catch{
            //print(error.localizedDescription)
        }
    }
    
    func startRecording(){
        // MARK: Temporary URL for recording Video
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopRecording(){
        output.stopRecording()
        DispatchQueue.main.async {
            self.isRecording = false
            self.showReatkeChooseButton = true
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            //print(error.localizedDescription)
            return
        }
        
        // CREATED SUCCESSFULLY
        //print("outputFileURL mov: \(outputFileURL)")
        self.recordedURLs.append(outputFileURL)
        if self.recordedURLs.count == 1{
            DispatchQueue.main.async {
                self.previewURL = outputFileURL
                
                withAnimation(.linear){
                    self.showPreview = true
                }
            }
            return
        }

    }
    
    public func changeCamera() {
        //        MARK: Here disable all camera operation related buttons due to configuration is due upon and must not be interrupted
        DispatchQueue.main.async {
            self.isRecordButtonDisabled = true
        }
        

        let currentVideoDevice = self.videoInput.device
        let currentPosition = currentVideoDevice.position
        
        let preferredPosition: AVCaptureDevice.Position
        let preferredDeviceType: AVCaptureDevice.DeviceType
        

        
        switch currentPosition {
        case .unspecified, .front:
            preferredPosition = .back
            preferredDeviceType = .builtInWideAngleCamera
            
        case .back:
            preferredPosition = .front
            preferredDeviceType = .builtInWideAngleCamera
            
        @unknown default:
            //print("Unknown capture position. Defaulting to back, dual-camera.")
            preferredPosition = .back
            preferredDeviceType = .builtInWideAngleCamera
        }
        let devices = self.videoDeviceDiscoverySession.devices
        var newVideoDevice: AVCaptureDevice? = nil
        
        // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
        if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
            newVideoDevice = device
        } else if let device = devices.first(where: { $0.position == preferredPosition }) {
            newVideoDevice = device
        }
        
        if let videoDevice = newVideoDevice {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                self.session.beginConfiguration()
                
                // Remove the existing device input first, because AVCaptureSession doesn't support
                // simultaneous use of the rear and front cameras.
                self.session.removeInput(self.videoInput)
                
                self.session.removeOutput(self.output)
                
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.videoInput = videoDeviceInput
                } else {
                    self.session.addInput(self.videoInput)
                }
                
                if self.session.canAddOutput(self.output){
                    self.session.addOutput(self.output)
                    
                    if let videoConnection = self.output.connection(with: .video){
                        if self.videoInput.device.position == .front {
                        
                            videoConnection.isVideoMirrored = true
                        }
                     }
                    
                } else {
                    self.session.addOutput(self.output)
                    
                    if let videoConnection = self.output.connection(with: .video){
                        if self.videoInput.device.position == .front {
                        
                            videoConnection.isVideoMirrored = true
                        }
                     }
                }
                self.session.commitConfiguration()
            } catch {
                //print("Error occurred while creating video device input: \(error)")
            }
            
            
            DispatchQueue.main.async {
//                MARK: Here enable capture button due to successfull setup
                self.isRecordButtonDisabled = false
            }
        }
    }
    
    func stopLoopingPlayer(){
        // make sure player is not nil although it won't be nil as this function is called after player is created in CustomLoopingPlayerView()
        DispatchQueue.main.async {
            if let play = self.player {
                        //print("stopped")
                        play.pause()
                    self.player = nil
                        //print("player deallocated")
                    } else {
                        //print("player was already deallocated")
                    }
        }
    }
    
    
    func convertVideo(callback: @escaping (Bool) -> Void) {

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            try FileManager.default.removeItem(at: directory.appendingPathComponent("main_video.mp4"))
            //print("File deleted")
        } catch {
            //print("No file to delete")
        }
        let videoSettings: [String: Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 100],
            AVVideoCodecKey: AVVideoCodecType.h264
        ]
        
        // for observing size of output file
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        
        let avAsset = AVURLAsset(url: self.previewURL!, options: videoSettings)
        // there are other presets than AVAssetExportPresetPassthrough
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)!
        exportSession.outputURL = directory.appendingPathComponent("main_video.mp4")
        // now it is actually in an mpeg4 container
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession.timeRange = range
        
        //print("Estimated size for mp4: \(formatter.string(fromByteCount: Int64(exportSession.estimatedOutputFileLength)))")
        
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .failed:
                break
                //print("%@", exportSession.error!)
            case .cancelled:
                break
                //print("Export canceled")
            case .completed:
                // Video conversion finished
                //print("Export finished")
                self.uploadVideoURL = directory.appendingPathComponent("main_video.mp4")
                
                self.sendVideo(){ response in
                    callback(true)
                }

            default:
                break
            }

        })
    }

    func sendVideo(callback: @escaping (Bool) -> Void) {
        let main = MainController() as MainController

        let videoData: Data!
        
        do {
            try videoData = Data(contentsOf: self.uploadVideoURL!)
            //print("Size for mp4: \(videoData.count/1024) KB")

            main.uploadSingleProfileVideo(videoData) { (dictionary) in
                if let videoUrl = dictionary["url"] {
                    let newVideoUrl = videoUrl as! String
                    callback(true)
                }
            }
        } catch {

        }
    }
    
    func startCircularProgress() {
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                withAnimation() {
                    self.circleProgress += 0.1
                    if self.circleProgress >= self.maxDuration || self.isRecording == false {
                        timer.invalidate()
                        self.stopRecording()
                        self.isRecordButtonDisabled = true
                        // used when you tap flip button during recording
                        if self.isFlipButtonPressed {
                            self.isRecordButtonDisabled = false
                            self.circleProgress = 0.0
                        } 
                    }
                }
            }
        }
    
}


extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)

        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}
