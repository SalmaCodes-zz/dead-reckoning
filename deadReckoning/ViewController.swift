//
//  ViewController.swift
//  deadReckoning
//
//  Created by Salma Suliman on 5/3/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var motionManager = CMMotionManager()
    
    let opQueue = OperationQueue()
    let pedometer: CMPedometer = CMPedometer()
    
    
    var paceCount = 0
    var distance = 0
    var azimuth = 0
    var steps = 0
    
    @IBOutlet weak var distanceSoFarLabel: UILabel!
    @IBOutlet weak var currentAzimuth: UILabel!
    
    @IBOutlet weak var magHeadingLabel: UILabel!
    @IBOutlet weak var trueHeadingLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    
    @IBOutlet weak var greenArrow: UILabel!
    @IBOutlet weak var rightRedArrow: UILabel!
    @IBOutlet weak var leftRedArrow: UILabel!
    
    @IBOutlet weak var paceCountTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var azimuthTextField: UITextField!
    
    @IBOutlet weak var walkStopButton: UIButton!
    
    var isWalking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if motionManager.isDeviceMotionAvailable {
            print("We can detect device motion")
            reset()
            startReadingMotionData()
        }
        else {
            print("We cannot detect device motion")
        }        
    }
    
    func reset() {
        // Hide arrows
        greenArrow.isHidden = true
        rightRedArrow.isHidden = true
        leftRedArrow.isHidden = true
        distanceSoFarLabel.text = "0m"
        pedometer.stopUpdates() 
        steps = 0
        disableWalkStopButton()
    }
    
    func disableWalkStopButton() {
        walkStopButton.isEnabled = false
        walkStopButton.backgroundColor = UIColor.gray
        walkStopButton.setTitle("Walk", for: .normal)
    }
    
    func enableWalkButton() {
        walkStopButton.isEnabled = true
        walkStopButton.backgroundColor = UIColor(red: 0, green: 0.8667, blue: 0.098, alpha: 1.0)
        walkStopButton.setTitle("Walk", for: .normal)
    }
    
    func enableStopButton() {
        walkStopButton.isEnabled = true
        walkStopButton.backgroundColor = UIColor.red
        walkStopButton.setTitle("Stop", for: .normal)
    }
    
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        let paceCountText: String? = paceCountTextField.text
        let distanceText: String? = distanceTextField.text
        let azimuthText: String? = azimuthTextField.text
        
        if let pc = paceCountText {
            paceCount = Int(pc)!
            
        }
        if let d = distanceText {
            distance = Int(d)!
        }
        if let a = azimuthText {
            azimuth = Int(a)!
        }
        print("paceCount", paceCount, "distance", distance, "azimuth", azimuth)
        self.view.endEditing(true)
        enableWalkButton()
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        reset()
    }
    
    @IBAction func walkStopButtonPressed(_ sender: UIButton) {
        isWalking = !isWalking
        print(isWalking)
        if (isWalking) {
            enableStopButton()
            pedometer.startUpdates(from:Date(), withHandler: { data, error in
                print("Update \(data?.numberOfSteps ?? 0)")
                
                DispatchQueue.main.async() {
                    self.steps = Int(truncating: data!.numberOfSteps)
                    let distance = ( self.steps * 100) / /* paceCount */ 110
                    
                    self.distanceSoFarLabel.text = String(distance) + "m"
                    self.detectCourse()
                }
            })
        } else {
            enableWalkButton()
            pedometer.stopUpdates()
        }
    }
    
    func detectCourse() {
        // TODO: replace currentAzimuth with azimuth from CoreLocation
        // TODO: Add logic for figuring out which arrow to show
        let currentAzimuthNumber = 4
        if (abs(azimuth - currentAzimuthNumber) < 5) {
            greenArrow.isHidden = false
            rightRedArrow.isHidden = true
            leftRedArrow.isHidden = true
        }
        
        
    }
    
    func startReadingMotionData() {
        // set read speed
        motionManager.deviceMotionUpdateInterval = 1

        // TODO: replace this with reading CoreLocation data??
        motionManager.startDeviceMotionUpdates(to: opQueue) {
            (data: CMDeviceMotion?, error: Error?) in
            if let err = error {
                print("\nError: " + err.localizedDescription)
            }
            if let mydata = data {
                DispatchQueue.main.async {
                    self.currentAzimuth.text = String(mydata.attitude.pitch) + "º"
                }
            }
        }
    }
    
    func degrees(_ radians: Double) -> Double {
        return 180/Double.pi * radians
    }
}

