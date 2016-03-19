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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}

