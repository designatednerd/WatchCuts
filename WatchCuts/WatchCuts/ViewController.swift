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
    var sampelRate = 1/60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFile()
        let velocityX = calculateVelocityX(accellerations!)
        let velocityY = calculateVelocityY(accellerations!)
        let velocityZ = calculateVelocityZ(accellerations!)
        let totalVelocity = calculateTotalVelocity(velocityX, velocityY, velocityZ)
        
        NSLog("\(totalVelocity)")
        
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
            return $0 * sampelRate
        }
        
        let velocity =  exesWithSampleRate.reduce(0) {
            seed, item in
            return seed + item
        }
        return abs(velocity)
    }
    
    func calculateVelocityY(accelerations: [Acceleration]) -> Double {
        let exes = accelerations.map{
            return $0.y
        }
        let exesWithSampleRate = exes.map{
            return $0 * sampelRate
        }
        
        let velocity =  exesWithSampleRate.reduce(0) {
            seed, item in
            return seed + item
        }
        return abs(velocity)
    }
    
    func calculateVelocityZ(accelerations: [Acceleration]) -> Double {
        let exes = accelerations.map{
            return $0.z
        }
        let exesWithSampleRate = exes.map{
            return $0 * sampelRate
        }
        
        let velocity =  exesWithSampleRate.reduce(0) {
            seed, item in
            return seed + item
        }
        return abs(velocity)
    }
    
    func calculateTotalVelocity(velocityX: Double, _ velocityY: Double, _ velocityZ: Double) -> Double {
        return sqrt(velocityX + velocityY + velocityZ)
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

