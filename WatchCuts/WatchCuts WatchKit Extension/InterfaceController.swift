//
//  InterfaceController.swift
//  WatchCuts WatchKit Extension
//
//  Created by Ellen Shapiro on 3/19/16.
//  Copyright © 2016 Baseball Hack Day 2016. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var speedLabel: WKInterfaceLabel!
    @IBOutlet var xLabel: WKInterfaceLabel!
    @IBOutlet var yLabel: WKInterfaceLabel!
    @IBOutlet var zLabel: WKInterfaceLabel!
    
    let motionManager = CMMotionManager()
    let motionQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        return queue
    }()
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    var accelerations = [Acceleration]()
    
    //MARK: Interface Controller Lifecycle
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.speedLabel.setText("O HAI")
        
        self.whatDoWeGot()
        self.motionManager.accelerometerUpdateInterval = Double(1/60)
        
        self.motionManager.startAccelerometerUpdatesToQueue(self.motionQueue, withHandler: self.accelerometerHandler())
    }


    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        self.motionManager.stopAccelerometerUpdates()
        
        NSLog("Accelerations: \(accelerations)")
        
        if WCSession.isSupported() {
            self.session = WCSession.defaultSession()
            self.session?.sendMessage(["accels": self.accelerations], replyHandler: {
                    [weak self]
                    dictionary in
                
                    if dictionary["success"] as? Bool == true {
                        self?.accelerations.removeAll()
                        NSLog("RESET ACCELS")
                    }
                },
                errorHandler: {
                    error in
                    NSLog("ERROR: \(error)")
            })
        }
        
        super.didDeactivate()
    }

    //MARK: Motion!
    
    private func whatDoWeGot() {
        if self.motionManager.accelerometerAvailable {
            NSLog("ACCELLEROMETER")
        }
        
        if self.motionManager.gyroAvailable {
            NSLog("GYRO")
        }
        
        if self.motionManager.magnetometerAvailable {
            NSLog("MAGNETOMETER")
        }
        
        if self.motionManager.deviceMotionAvailable {
            NSLog("DEVICE MOTION")
        }
    }
    
    private func accelerometerHandler() -> CMAccelerometerHandler {
        return {
            [weak self]
            accelerometerData, error in
            
            if let accelerometerError = error {
                NSLog("ERRORZ: \(accelerometerError.localizedDescription)")
                return
            }
            
            if let data = accelerometerData {
                let acceleration = data.acceleration
                self?.accelerations.append(Acceleration.fromCMAcceleration( acceleration))
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self?.xLabel.setText("x: \(acceleration.x)")
                    self?.yLabel.setText("y: \(acceleration.y)")
                    self?.zLabel.setText("z: \(acceleration.z)")
                }
            }
        }
    }
    
}

extension InterfaceController: WCSessionDelegate {
    
}
