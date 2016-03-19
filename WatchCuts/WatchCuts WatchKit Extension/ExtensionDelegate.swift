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
    
    let recorder = CMSensorRecorder()
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
    var flushing = false
    
    
    //MARK: Extension  Lifecycle
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            self.recorder.recordAccelerometerForDuration(20 * 60)
        }
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("DID BECOME ACTIVE")
        
        self.session = WCSession.defaultSession()
        
        self.updateUI()
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateUI", userInfo: nil, repeats: true)
    }
    
    func updateUI() {
        let now = NSDate()
        guard let dataList = self.recorder.accelerometerDataFromDate(now.dateByAddingTimeInterval(-5), toDate: now) else {
            NSLog("NO DATA FOR YOU")
            return
        }
        
        
        for (_, item) in dataList.enumerate() {
            guard let data = item as? CMRecordedAccelerometerData else {
                NSLog("NOT UR DATASZ")
                return
            }
            
            let accel = Acceleration(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
            accelerations.append(accel)
            print("\(accel)")
        }
        
        
        guard let lastAccel = self.accelerations.last else {
            return
        }
        //Update UI
        if let interfaceController = WKExtension.sharedExtension().rootInterfaceController as? InterfaceController {
            interfaceController.updateUIWithAccelleration(lastAccel)
        }
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        
        self.flushAccellerationsToPhone(self.accelerations)
        
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
                
                guard let strongSelf = self else {
                    NSLog("BAIL 1")
                    return
                }
                
                strongSelf.accelerations.append(fromCM)

                NSOperationQueue.mainQueue().addOperationWithBlock {
                    //Update UI
                    if let interfaceController = WKExtension.sharedExtension().rootInterfaceController as? InterfaceController {
                        interfaceController.updateUIWithAccelleration(fromCM)
                    }
                    
                    guard let ss2 = self else {
                        NSLog("BAIL 2!")
                        return
                    }
                    
                    if ss2.accelerations.count > 100 && !ss2.flushing {
                        let first100 = ss2.accelerations.prefix(100)
                        ss2.flushAccellerationsToPhone(Array(first100))
                    }
                }
            }
        }
    }
    
    func flushAccellerationsToPhone(flushMe: [Acceleration]) {
//        if WCSession.isSupported() {
//            NSLog("FLOOSH \(flushMe.count)")
//            self.flushing = true
//            let encoded = NSKeyedArchiver.archivedDataWithRootObject(flushMe)
//            self.session?.sendMessage([WatchKitMessageKey.accels.rawValue: encoded],
//                replyHandler: {
//                    [weak self]
//                    dictionary in
//                    
//                    if let strongSelf = self {
//                        if let success = dictionary[WatchKitMessageKey.success.rawValue] as? NSNumber where success.boolValue == true {
//                            strongSelf.accelerations = Array(strongSelf.accelerations.dropFirst(flushMe.count))
//                            strongSelf.flushing = false
//                            NSLog("RESET ACCELS")
//                        } else {
//                            NSLog("DINNAE GET RETURN")
//                        }
//                        
//                    } else {
//                        NSLog("SELFLESS")
//                    }
//                },
//                errorHandler: {
//                    error in
//                    NSLog("ERROR: \(error)")
//            })
//        } else {
//            NSLog("SESSION NOT SUPPORTED")
//        }
    }
}

extension CMSensorDataList: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}

