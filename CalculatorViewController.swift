//
//  ViewController.swift
//  Calculator
//
//  Created by Jared Felton-Grice on 7/8/15.
//  Copyright (c) 2015 Jared F.G. All rights reserved.
//

import UIKit



class CalculatorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calHistory.text = " "
        display.text = "lets do some math 😁"
        display.textColor = UIColor.lightGrayColor()
        
    }
    var displayValue: Double?{ //make an optional
        get {
            if let number =  NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return number
            }
            else {
                return nil
            }
        }
        set {
            display.text = "\(newValue!)"
            userIsTypingANumber = false
        }
    }
    
    var userIsTypingANumber = false
    
    var brain = CalculatorBrain()

    @IBOutlet weak var display : UILabel!
    
    @IBOutlet weak var calHistory: UILabel!
    
    @IBAction func setM(sender: AnyObject) {
        brain.variableValues["M"] = displayValue
        userIsTypingANumber = false
        display.text = " "
    }
    @IBAction func pushM(sender: AnyObject) {
        brain.pushOperand("M")
    }
    
    
    @IBAction func changeSign() { // fix this
    if (displayValue != nil){
        if(userIsTypingANumber){
            let valDisplay: Double = displayValue!
            if (displayValue >= 0 ){
                var oldText = display.text!
                display.text = "-\(oldText)"
            }
            else{
                display.text = "\(abs(valDisplay))"
            }
        }
        else { brain.makeLastOpposite() }
    }
}
    
    
    @IBAction func clear() {
        display.text = "All Clear"
        calHistory.text = " "
        brain.clear() //remove all from stack
        brain.variableValues.removeValueForKey("M")

    }
   
    @IBAction func back(){
        if(userIsTypingANumber){
            if (count(display.text!) > 0 ){
                display.text = dropLast(display.text!)
            }
            else{
                userIsTypingANumber = false
                display.text = "nothing to delete 😓"
                display.textColor = UIColor.lightGrayColor()
                
            }
        }
    }
    
    @IBAction func addNumber (sender: UIButton){
        let number = sender.currentTitle!
        
        if (userIsTypingANumber){
            display.text = display.text! + number
        } else {
            display.text = number
            userIsTypingANumber = true
        }
    }
    
    @IBAction func enter(){
        userIsTypingANumber = false
        if let result = brain.pushOperand(displayValue!){
            displayValue = result
        }
        else{
            display.text = " "
        }
    }
   
    
    @IBAction func piEntered(sender: AnyObject) {
        if (userIsTypingANumber){
            enter()
        }
        brain.pushOperand("π")
        brain.variableValues["π"] = M_PI //add M_PI to stack
        display.text = "π"
    }
    
    @IBAction func operate(sender: AnyObject) {
       
        if (userIsTypingANumber) {enter()}
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation!){
                displayValue = result
                calHistory.text = brain.description +  "  =  " + display.text!
            }else {
                displayValue = 0
            }
        }
    }
}

