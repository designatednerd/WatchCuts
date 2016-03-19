//
//  ViewController.swift
//  WatchCuts
//
//  Created by Ellen Shapiro on 3/19/16.
//  Copyright © 2016 Baseball Hack Day 2016. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var batLengthQuestionLabel: UILabel!
    @IBOutlet weak var batLengthField: UITextField!
    @IBOutlet weak var submitBatLengthButton: UIButton!
    
    @IBAction func submitBatLength(sender: UIButton) {
        batLengthField.resignFirstResponder()
    }
    let batLengthUserKey = "batLength"
    
    var accellerations: [Acceleration]?
    var velocities: [Double]?
    var sampleRate = 1/60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFile()
        let velocityX = calculateVelocityX(accellerations!)
        let velocityY = calculateVelocityY(accellerations!)
        let velocityZ = calculateVelocityZ(accellerations!)
        let avergeVelocity = calculateAverageVelocity(velocityX, velocityY, velocityZ)
        
        let velocityXOverTime = calculateVelocityXOverTime(accellerations!)
        
        
        batLengthField.delegate = self
        let defaults = NSUserDefaults.standardUserDefaults()
        if let batLength = defaults.stringForKey(batLengthUserKey) {
            batLengthField.text = batLength
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        batLengthField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(batLengthField: UITextField) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(batLengthField.text, forKey: batLengthUserKey)
    }
    
    func calculateVelocityX(accelerations: [Acceleration]) -> Double {
        let exes = accelerations.map{
            return $0.x
        }
        
        let exesWithSampleRate = exes.map{
            return $0 * sampleRate
        }
        
        let velocity =  exesWithSampleRate.reduce(0) {
            seed, item in
            return seed + item
        }
        return velocity
    }
    
    func calculateVelocityY(accelerations: [Acceleration]) -> Double {
        let exes = accelerations.map{
            return $0.y
        }
        let exesWithSampleRate = exes.map{
            return $0 * sampleRate
        }
        
        let velocity =  exesWithSampleRate.reduce(0) {
            seed, item in
            return seed + item
        }
        return velocity
    }
    
    func calculateVelocityZ(accelerations: [Acceleration]) -> Double {
        let exes = accelerations.map{
            return ($0.z)
        }
        let exesWithSampleRate = exes.map{
            return $0 * sampleRate
        }
        
        let velocity =  exesWithSampleRate.reduce(0) {
            seed, item in
            return seed + item
        }
        return velocity
    }
    
    func calculateAverageVelocity(velocityX: Double, _ velocityY: Double, _ velocityZ: Double) -> Double {
        return sqrt(abs(velocityX) + abs(velocityY) + abs(velocityZ))
    }
    
    func calculateVelocityXOverTime(accelerations: [Acceleration]) -> [Double]{
        var velocities = [Double]()
        for index in 1..<accelerations.count {
            let velocityX = calculateVelocityX([accelerations[index-1], accelerations[index]])
            velocities.append(velocityX)
        }
        
        for index in 1..<velocities.count {
            velocities[index] += velocities[index - 1]
        }
        return velocities.map{
            return $0 * -1
        }
    }
    
    //MARK: Data loading
    
    func loadDataFromFile() {
        guard
            let file = NSBundle.mainBundle().pathForResource("data", ofType: "txt") else {
            assertionFailure("Couldn't find file!")
            return
        }
        
        guard let fromFile = try? String(contentsOfFile: file) else {
            assertionFailure("Couldn't load file")
            return
        }

        //Split string here
        
        let linePoints = fromFile.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        let stringPointsArray = linePoints.map{
            return $0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()).stringByTrimmingCharactersInSet(.punctuationCharacterSet())
        }
        let pointsArray = stringPointsArray.map{
            return Acceleration.fromDescription($0)
        }
        accellerations = pointsArray
    }
    
}

