//
//  CalculatorViewController.swift
//  Calculator
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private var brain = CalculatorBrain()
    private var userIsInTheMiddleOfTypingANumber = false
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            display.text = newValue?.description ?? "0"
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
            display.text = digit
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
        history.text = brain.description ?? " "
    }
    
    @IBAction func clear() {
        if userIsInTheMiddleOfTypingANumber {
            if countElements(display.text!) > 1 {
                display.text = dropLast(display.text!)
            }
            else {
                userIsInTheMiddleOfTypingANumber = false
                display.text = "0"
            }
        }
        else {
            brain.removeLast()
            updateDisplay()
        }
    }
}
