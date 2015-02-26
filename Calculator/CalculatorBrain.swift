//
//  CalculatorBrain.swift
//  Calculator
//

import Foundation

class CalculatorBrain {
    
    private enum Op: Printable {
        case Operand(Double)
        case Constant(String, Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Constant(let constant, _):
                    return constant
                case .Variable(let variable):
                    return variable
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .Operand(_):
                    return 4
                case .Constant(_, _):
                    return 4
                case .Variable(_):
                    return 4
                case .UnaryOperation(_, _):
                    return 3
                case .BinaryOperation(_, let value, _):
                    return value
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", 2, *))
        learnOp(Op.BinaryOperation("÷", 2, /))
        learnOp(Op.BinaryOperation("+", 1, +))
        learnOp(Op.BinaryOperation("−", 1, -))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.Constant("π", M_PI))
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                opStack = [Op]()
                for opSymbol in opSymbols {
                    if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        pushOperand(operand)
                    }
                    else {
                        pushOperand(opSymbol)
                    }
                }
            }
        }
    }
    
    func pushOperand(operand: Double) {
        opStack.append(Op.Operand(operand))
    }
    
    func pushOperand(variable: String) {
        opStack.append(Op.Variable(variable))
        if variableValues[variable] == nil {
            variableValues[variable] = nil
        }
    }
    
    func performOperation(symbol: String) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }
    
    func evaluate() -> Double? {
        return evaluate(opStack).result
    }
    
    private func evaluate(var remainingOps: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !remainingOps.isEmpty {
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Constant(_, let value):
                return (value, remainingOps)
            case .Variable(let variable):
                if let value = variableValues[variable] {
                    return (value, remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand2, operand1), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, remainingOps)
    }
    
    var description: String {
        get {
            var vars = ""
            for (key, value) in variableValues {
                vars += "\(key)=\(value)\n"
            }
            for op in opStack {
                switch op {
                case .Variable(let key):
                    if variableValues.indexForKey(key) == nil {
                        vars += "\(key)=?\n"
                    }
                default: break
                }
            }
            var output = ""
            var remainingOps = opStack
            while !remainingOps.isEmpty {
                var subOut: String
                (subOut, _, remainingOps) = describe(remainingOps)
                output = subOut + "\n" + output
            }
            return vars + output
        }
    }
    
    private func describe(var ops: [Op]) -> (expression: String, precedence: Int, remainingOps: [Op]) {
        if ops.isEmpty {
            return ("?", 4, ops)
        }
        let op = ops.removeLast()
        switch op {
        case .UnaryOperation(_, _):
            var subOut: String
            var remainingOps: [Op]
            (subOut, _, remainingOps) = describe(ops)
            return ("\(op)(\(subOut))", op.precedence, remainingOps)
        case .BinaryOperation(_, let precedence, _):
            var leftOut: String
            var leftPrecedence: Int
            var leftRemaining: [Op]
            var rightOut: String
            var rightPrecedence: Int
            var rightRemaining: [Op]
            (rightOut, rightPrecedence, rightRemaining)  = describe(ops)
            (leftOut, leftPrecedence, leftRemaining) = describe(rightRemaining)
            var output = ""
            if leftPrecedence < precedence {
                output += "(\(leftOut))"
            }
            else {
                output += leftOut
            }
            output += "\(op)"
            if rightPrecedence < precedence {
                output += "(\(rightOut))"
            }
            else {
                output += rightOut
            }
            return (output, precedence, leftRemaining)
        default:
            return ("\(op)", op.precedence, ops)
        }
    }
    
}