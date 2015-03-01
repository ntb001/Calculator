//
//  ViewController.swift
//  Calculator
//

import UIKit

class ViewController: UIViewController {
    
    var brain = CalculatorBrain()
    var userIsInTheMiddleOfTypingANumber = false
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            }
            else {
                display.text = " "
                userIsInTheMiddleOfTypingANumber = false
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if (digit != "." || display.text!.rangeOfString(".") ==  nil) {
                display.text = display.text! + digit
            }
        }
        else {
            userIsInTheMiddleOfTypingANumber = true
            if digit == "." {
                display.text = "0."
            }
            else {
                display.text = digit
            }
        }
    }
    
    @IBAction func setM() {
        userIsInTheMiddleOfTypingANumber = false
        brain.variableValues.updateValue(displayValue!, forKey: "M")
        updateDisplay()
    }
    
    @IBAction func getM() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        brain.pushOperand("M")
        updateDisplay()
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            if countElements(display.text!) > 1 {
                display.text = dropLast(display.text!)
            }
            else {
                userIsInTheMiddleOfTypingANumber = false
                display.text = "0"
            }
        }
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        brain.pushOperand(displayValue!)
        updateDisplay()
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        brain.performOperation(operation)
        updateDisplay()
    }
    
    @IBAction func plusOrMinus() {
        if let value = displayValue {
            displayValue = value * -1
        }
    }
    
    private func updateDisplay() {
        displayValue = brain.evaluate()
        history.text = brain.description
    }
    
    @IBAction func clear() {
        display.text = "0"
        history.text = " "
        brain = CalculatorBrain()
    }
}

