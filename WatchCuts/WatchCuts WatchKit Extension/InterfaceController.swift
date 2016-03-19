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
    

    
    //MARK: Interface Controller Lifecycle
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        self.speedLabel.setText("O HAI")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }


    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    //MARK: Motion!
    
    func updateUIWithAccelleration(acceleration: Acceleration) {
        self.xLabel.setText("x: \(acceleration.x)")
        self.yLabel.setText("y: \(acceleration.y)")
        self.zLabel.setText("z: \(acceleration.z)")
    }
}

