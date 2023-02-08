//
//  WaveUsedPopUP.swift
//  Krown
//
//  Created by Apple on 29/09/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class WaveUsedPopUP: UIViewController {
    
    //MARK: - outlet
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var vwParent: UIView!
    
    //MARK: - variable
    var time = ""
    var timer : Timer?
    var sec : Int = 60
    var min : Int = 60
    var hour : Int = 24
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        vwParent.addGestureRecognizer(tap)
        setupView()
    }
    
    //MARK: - button click
    
    @IBAction func btnContinueClicked(_ sender: UIButton) {
        dismissView()
    }
    
    
    //MARK: - other methods
    
    func setupView(){
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.3, delay:
                    0.3, options: [], animations: {
                self.vwParent.backgroundColor = .slateGrey.withAlphaComponent(0.5)

            })
        }
        
        sec = Int(time.components(separatedBy: ":")[2]) ?? 0
        min = Int(time.components(separatedBy: ":")[1]) ?? 0
        hour = Int(time.components(separatedBy: ":")[0]) ?? 0
        setTimeOnLabel()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(upDateTime), userInfo: nil, repeats: true)
    }
    
    func dismissView(){
        timer?.invalidate()
        let dismissalTime = 0.3
        UIView.animate(withDuration: dismissalTime) {
            self.vwParent.backgroundColor = .slateGrey.withAlphaComponent(0.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+dismissalTime) {
            self.dismiss(animated: true)
        }
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissView()
    }

    
    @objc func upDateTime()
    {
        if sec != 0{
            sec -= 1
        }
        
        if sec  == 0
        {
            if min != 0{
                min -= 1
                sec = 60
                setTimeOnLabel()
            }
            if min == 0
            {
                
                if hour != 0 {
                    hour -= 1
                    min = 60
                    setTimeOnLabel()
                }
                else{
                    if sec == 0 && min == 0 && hour == 0{
                        timer?.invalidate()
                        UserDefaults.standard.set(false, forKey: WebKeyhandler.User.isWaveUsedUp)
                        UserDefaults.standard.set("", forKey: WebKeyhandler.User.waveResetAt)
                        UserDefaults.standard.synchronize()
                        dismissView()
                    }
                    else{
                        setTimeOnLabel()
                    }
                    
                }
            }
            
        }
        else{
           setTimeOnLabel()
        }
    }
    
    func setTimeOnLabel(){
        var new_sec = "\(sec)"
        var new_min = "\(min )"
        var new_hr = "\(Int(hour) )"
        if new_sec.count == 1{
            new_sec = "0\(new_sec)"
        }
        if new_min.count == 1{
            new_min = "0\(new_min)"
        }
        if new_hr.count == 1
        {
            new_hr = "0\(new_hr)"
        }
        lblTime.text = new_hr + ":" + new_min + ":" + new_sec
    }

}
