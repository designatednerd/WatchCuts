//
//  Acceleration.swift
//  WatchCuts
//
//  Created by Ellen Shapiro on 3/19/16.
//  Copyright © 2016 Baseball Hack Day 2016. All rights reserved.
//

import Foundation
import CoreMotion

class Acceleration: NSObject {
    
    let x: Double
    let y: Double
    let z: Double
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let x = aDecoder.decodeObjectForKey("x") as? Double,
            let y = aDecoder.decodeObjectForKey("y") as? Double,
            let z = aDecoder.decodeObjectForKey("z") as? Double else {
                return nil
        }
        
        self.init(x: x, y: y, z: z)
    }
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
        
        super.init()
    }
    
    static func fromCMAcceleration(acceleration: CMAcceleration) -> Acceleration {
        return Acceleration(x: acceleration.x,
            y: acceleration.y,
            z: acceleration.z)
    }
    
    static func fromDescription(description: String) -> Acceleration {
        let elements = description.componentsSeparatedByString(",")
        
        //TODO: Figure out why mapping this is failing spectacularly
        var numberStrings = [String]()
        for element in elements {
            let bits = element.componentsSeparatedByString(": ")
            if let lastBit = bits.last {
                numberStrings.append(lastBit)
            }
        }
        
        let doubles = numberStrings.map { Double($0) }
        assert(doubles.count == 3, "Not enough numbers!")
        return Acceleration(x: doubles[0]!, y: doubles[1]!, z: doubles[2]!)
    }
    
    override var description: String {
        return "\nx: \(self.x), y: \(self.y), z: \(self.z)"
    }
}

extension Acceleration: NSCoding {
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.x, forKey: "x")
        aCoder.encodeObject(self.y, forKey: "y")
        aCoder.encodeObject(self.z, forKey: "z")
    }
}
