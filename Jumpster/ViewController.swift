//
//  ViewController.swift
//  Jumpster
//
//  Created by Ryan Pan on 11/4/16.
//  Copyright © 2016 Ryan Pan. All rights reserved.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    
    let manager = CMMotionManager()
    let timer = NSTimer.init()
    var time = 0.0
    var offtime = 0.0
    let interval = 0.001
    var Gs = 3.0
    var startstop = false
    var timerOn = false
    var isCm = true
    
    @IBOutlet weak var airtimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var GLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    
    func isjump(x: Double, y: Double, z: Double) -> Bool {
        if sqrt(pow(x,2) + pow(y,2) + pow(z,2)) > Gs {
            return true
        }
        return false
    }
    
    @IBAction func toggle(sender: AnyObject) {
        if(isCm){
            let cmDistance = Double(distanceLabel.text!)!
            distanceLabel.text = String(cmDistance * 0.39)
            unitsLabel.text = "Vertical Distance (in)"
            isCm = false
        }
        else{
            let inDistance = Double(distanceLabel.text!)!
            distanceLabel.text = String(inDistance / 0.39)
            unitsLabel.text = "Vertical Distance (cm)"
            isCm = true
        }
    }
    
    func updateTime(){
        if timerOn{
            time += interval
        }
        else{
            offtime += interval
        }
    }
    @IBAction func GsMoved(sender: UISlider) {
        Gs = Double(sender.value)
        GLabel.text = String(format:"%.1f", Gs)
    }
    
    func calcVertDistance(){
        if time > 1.5{
            airtimeLabel.text = "invalid"
            distanceLabel.text = "invalid"
            return
        }
        let vi = (9.8 * (time-0.1)/2)
        let distance = pow(vi,2) / (2 * 9.8) * 100
        distanceLabel.text = String(distance)
    }

    @IBAction func resetPressed(sender: UIButton) {
        timerOn = false
        time = 0
        offtime = 0
        distanceLabel.text = "0"
        airtimeLabel.text = "0"
        unitsLabel.text = "Vertical Distance (cm)"
        isCm = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSTimer.scheduledTimerWithTimeInterval(interval, target:self, selector: #selector(ViewController.updateTime), userInfo:nil, repeats: true)
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.001
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                if let acceleration = data?.userAcceleration {
                    if self!.isjump(acceleration.x, y:acceleration.y, z:acceleration.z) {
                        //jumps are at least .1 seconds
                        if self!.timerOn && self!.time < 0.1 {
                            return
                        }
                        //after jump stops don't detect another jump for .1 seconds
                        if !self!.timerOn && self!.offtime < 0.1 {
                            return
                        }
                        self!.timerOn = !self!.timerOn
                        if !self!.timerOn {
                            self!.airtimeLabel.text = String(self!.time)
                            self!.calcVertDistance()
                            self!.unitsLabel.text = "Vertical Distance(cm)"
                            self!.time = 0
                            self!.isCm = true
                        }
                        else{
                            self!.offtime = 0
                        }
                        
                    }
                }
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

