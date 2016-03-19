//
//  ViewController.swift
//  WatchCuts
//
//  Created by Ellen Shapiro on 3/19/16.
//  Copyright © 2016 Baseball Hack Day 2016. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, CPTPlotDataSource {
    

    @IBOutlet weak var batLengthField: UITextField!
    @IBOutlet weak var batLengthQuestionLabel: UILabel!
    @IBOutlet weak var submitBatLengthButton: UIButton!
    @IBOutlet weak var showVelocities: UIButton!
    @IBOutlet weak var velocityDisplayLabel: UILabel!
    @IBOutlet weak var maxXVelocity: UILabel!
    @IBOutlet weak var graphView: CPTGraphHostingView!
    
    @IBAction func showVelocities(sender: AnyObject) {
        velocityDisplayLabel.text = "\(averageVelocity)"
        maxXVelocity.text = "\(maximumVelocityX)"
    }
    @IBAction func submitBatLength(sender: UIButton) {
        batLengthField.resignFirstResponder()
    }
    let batLengthUserKey = "batLength"
    
    var accellerations: [Acceleration]?
    var velocities: [Double]?
    var sampleRate = 1/60.0
    var velocityXOverTime: [Double]?
    var averageVelocity: Double!
    var maximumVelocityX: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFile()
        let velocityX = calculateVelocityX(accellerations!)
        let velocityY = calculateVelocityY(accellerations!)
        let velocityZ = calculateVelocityZ(accellerations!)
        
        averageVelocity = calculateAverageVelocity(velocityX, velocityY, velocityZ)
        velocityXOverTime = calculateVelocityXOverTime(accellerations!)
        maximumVelocityX = calculateMaxVelocityX(velocityXOverTime!)
        
        
        batLengthField.delegate = self
        let defaults = NSUserDefaults.standardUserDefaults()
        if let batLength = defaults.stringForKey(batLengthUserKey) {
            batLengthField.text = batLength
        }
        
        createGraph();
    }
    
    func createGraph() {
        // create graph
        let graph = CPTXYGraph(frame: CGRectZero)
        graph.title = "Hello Graph"
        graph.paddingLeft = 0
        graph.paddingTop = 0
        graph.paddingRight = 0
        graph.paddingBottom = 0
        // hide the axes
        let axes = graph.axisSet as! CPTXYAxisSet
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 5
        axes.xAxis!.axisLineStyle = lineStyle
        axes.yAxis!.axisLineStyle = lineStyle
        
        // add a pie plot
        let pie = CPTPieChart()
        pie.dataSource = self
        pie.pieRadius = (self.view.frame.size.width * 0.9)/2
        graph.addPlot(pie)
        
        self.graphView.hostedGraph = graph
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return 4
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
            return ($0.x + 0.1)
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
            return ($0.y - 0.14)
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
            return ($0.z + 0.98)
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
            velocities.append(velocityX - 0.0033)
        }
        
        for index in 1..<velocities.count {
            velocities[index] += velocities[index - 1]
        }
        return velocities.map{
            return $0 * -1
        }
    }
    
    func calculateMaxVelocityX(velocities: [Double]) -> Double {
        var max = velocities[0]
        for index in 1..<velocities.count {
            if velocities[index] > max {
                max = velocities[index]
            }
        }
        return max
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

