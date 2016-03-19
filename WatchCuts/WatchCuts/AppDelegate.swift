//
//  AppDelegate.swift
//  WatchCuts
//
//  Created by Ellen Shapiro on 3/19/16.
//  Copyright © 2016 Baseball Hack Day 2016. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
}

extension AppDelegate: WCSessionDelegate {

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        if let accels = message["accels"] as? [Acceleration] {
            NSLog("Accelerations: \(accels)")
            replyHandler(["success": true])
        } else {
            NSLog("YOU CANNOT HAS")
            replyHandler(["success": false])
        }
    }
}