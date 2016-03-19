//
//  ExtensionDelegate.swift
//  WatchCuts WatchKit Extension
//
//  Created by Ellen Shapiro on 3/19/16.
//  Copyright © 2016 Baseball Hack Day 2016. All rights reserved.
//

import WatchKit
import CoreMotion
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    let motionManager = CMMotionManager()
    let motionQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        return queue
    }()
    var accelerations = [Acceleration]()
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    //MARK: Extension  Lifecycle
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("DID BECOME ACTIVE")
        
        self.session = WCSession.defaultSession()
        
        
        self.motionManager.accelerometerUpdateInterval = Double(1/60)
        self.motionManager.startAccelerometerUpdatesToQueue(self.motionQueue, withHandler: self.accelerometerHandler())
        
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        self.motionManager.stopAccelerometerUpdates()
        
        if WCSession.isSupported() {
            self.session?.sendMessage([WatchKitMessageKey.accels.rawValue: self.accelerations],
                replyHandler: {
                    [weak self]
                    dictionary in
                    
                    if dictionary[WatchKitMessageKey.success.rawValue] as? Bool == true {
                        self?.accelerations.removeAll()
                        NSLog("RESET ACCELS")
                    }
                },
                errorHandler: {
                    error in
                    NSLog("ERROR: \(error)")
            })
        }
        
        
        NSLog("WILL RESIGN ACTIVE")
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
                let fromCM = Acceleration.fromCMAcceleration( acceleration)
                self?.accelerations.append(fromCM)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    //Update UI
                    if let interfaceController = WKExtension.sharedExtension().rootInterfaceController as? InterfaceController {
                        interfaceController.updateUIWithAccelleration(fromCM)
                    }
                }
            }
        }
    }
}
