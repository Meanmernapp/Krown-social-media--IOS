//
//  takeVideoVC.swift
//  Krown
//
//  Created by KrownUnity on 29/11/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

// Learned from https://stackoverflow.com/questions/41697568/capturing-video-with-avfoundation

import UIKit
import AVFoundation

class takeVideoVC: UIViewController, AVCaptureFileOutputRecordingDelegate {

    // Camera
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var recordingBtnLbl: UIButton!
    @IBOutlet weak var useVideoBtnLbl: UIButton!

    let cameraButton = UIView()
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var counter = 0
    // VideoPlayer
    @IBOutlet weak var videoView: UIView!
    var avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var videoRecordedURL = URL(string: "")
    // Passed URL
    var PassedURL = String()
    // Timer
    var seconds: Int = 6 {
        didSet {
            countdownLabel.text = "\(seconds)"
        if seconds == 0 {startStopReset()}
        }

    }
    var timer = Timer()
    var isTimerRunning = false

    @IBAction func recordVideo(_ sender: Any) {
        // Button is called "Use Video"
        convertVideo()
    }
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func recordingBtn(_ sender: Any) {
        startStopReset()
    }

    func startStopReset() {
        if movieOutput.isRecording == false && avPlayer.isPlaying == false {
            // If movie is not recording -> start recording and show a stop btn and hide "use video" btn
            useVideoBtnLbl.isHidden = true
            startStopCapture()
            recordingBtnLbl.setTitle("Stop", for: .normal)
            runTimer()
        } else if movieOutput.isRecording == true {
            // If movie is recording -> stop recording and show a reset btn and make "use video" btn visible
            useVideoBtnLbl.isHidden = false
            recordingBtnLbl.setTitle("Reset", for: .normal)
            startStopCapture()
            timer.invalidate()
            seconds = 6
        } else {
            recordingBtnLbl.setTitle("Capture", for: .normal)
            videoView.isHidden = true
            avPlayer.pause()
            avPlayer.rate = 0
            useVideoBtnLbl.isHidden = true
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Views

        countdownView.layer.cornerRadius = 20
        camPreview.layer.cornerRadius = 20
        videoView.layer.cornerRadius = 20
        videoView.clipsToBounds = true
        camPreview.clipsToBounds = true
        useVideoBtnLbl.isHidden = true

        if setupSession() {
            setupPreview()
            startSession()
        }

    }

    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }

    // MARK: - Setup Camera

    func setupSession() -> Bool {

        captureSession.sessionPreset = AVCaptureSession.Preset.medium

        // Setup Camera
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)

        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            //print("Error setting device video input: \(error)")
            return false
        }

        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: .video)

        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            //print("Error setting device audio input: \(error)")
            return false
        }

        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        return true
    }

    func setupCaptureMode(_ mode: Int) {
        // Video Mode

    }

    // MARK: - Camera Session
    func startSession() {

        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }

    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation

        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }

        return orientation
    }

    @objc func startStopCapture() {

        startRecording()

    }

    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString

        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }

        return nil
    }

    func startRecording() {

        if movieOutput.isRecording == false {

            let connection = movieOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }

            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }

            let device = activeInput.device
                do {
                    try device.lockForConfiguration()
                    device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 15)
                    device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 15)
                    device.unlockForConfiguration()
                } catch {
                    //print("Error setting configuration: \(error)")
                }

            //print(activeInput.device.activeVideoMaxFrameDuration)
            //print(activeInput.device.activeVideoMinFrameDuration)

            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)

        } else {
            stopRecording()
        }

    }

    func stopRecording() {

        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            //print("Error recording movie: \(error!.localizedDescription)")
        } else {

            videoRecordedURL = outputURL! as URL
            playVideo(videoURL: videoRecordedURL!)

        }
        outputURL = nil
    }

    func playVideo(videoURL: URL) {

        videoView.isHidden = false

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem, queue: .main) { _ in
            self.avPlayer.seek(to: CMTime.zero)
            self.avPlayer.play()
        }

        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)

        view.layoutIfNeeded()

        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)

        avPlayer.play()
    }

    func convertVideo() {

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
            // AVVideoHeightKey: videoTrack.naturalSize.height,
            // AVVideoWidthKey: videoTrack.naturalSize.width
        ]

        let avAsset = AVURLAsset(url: videoRecordedURL!, options: videoSettings)
        // there are other presets than AVAssetExportPresetPassthrough
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputURL = directory.appendingPathComponent("main_video.mp4")
        // now it is actually in an mpeg4 container
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession.timeRange = range
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
                self.videoRecordedURL = directory.appendingPathComponent("main_video.mp4")
                self.sendVideo()

            default:
                break
            }

        })
    }

    func sendVideo() {
        let main = MainController() as MainController

        let videoData: Data!
        do {
            try videoData = Data(contentsOf: videoRecordedURL!)
            main.uploadSingleProfileVideo(videoData) { (dictionary) in
                if let videoUrl = dictionary["url"] {
                    let newVideoUrl = videoUrl as! String
                    self.dismissViewAndSaveImage(imageURL: newVideoUrl)
                }
            }
        } catch {

        }
    }
        @objc func updateTimer() {
        seconds -= 1
    }

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(takeVideoVC.updateTimer)), userInfo: nil, repeats: true)
    }

    func dismissViewAndSaveImage(imageURL: String) {
        PassedURL = imageURL
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
}
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
