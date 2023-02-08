//
//  PageControllCollCell.swift
//  Krown
//
//  Created by macOS on 19/01/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

protocol pageNextDelegate {
    func gotoNextPage()
    func getCurrentTime(_ time : Float)
}

class PageControllCollCell: UICollectionViewCell {

    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var pageView: CircularProgressView!
    var delegate : pageNextDelegate?
    var timer : Timer?
    var time : Float = Float()
    let secondsPerPicture = 3.200
    let framesPrSecond = 60.000
    override func awakeFromNib() {
        super.awakeFromNib()
        v1.layer.cornerRadius = 5
        pageView.layer.cornerRadius = 5
        pageView.layer.masksToBounds = true
        // Initialization code
    }
    func startTimer(_ timeSec : Float) {
//        //print("Start Timer")
        time = timeSec
        let timerTime = Double(secondsPerPicture/framesPrSecond)
        self.pageView.progress = time
        timer = Timer.scheduledTimer(timeInterval: timerTime, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }

    @objc func updateCounting(){
        let increase = Float(secondsPerPicture/framesPrSecond/secondsPerPicture)
        time += increase
//        print("time - \(time)")
        delegate?.getCurrentTime(time)
        pageView.progress = time
        if time > 1 {
            timer?.invalidate()
            pageView.isHidden = true
            delegate?.gotoNextPage()
        }
    }

}
