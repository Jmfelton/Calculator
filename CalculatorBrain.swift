//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jared Felton-Grice on 7/9/15.
//  Copyright (c) 2015 Jared F.G. All rights reserved.
//

import Foundation

class CalculatorBrain{
    
    enum Op : Printable
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double,Double) -> Double)
        case Variable(String)
        case NullaryOperation(String, () -> Double)
        
        var description: String {
            get{
                switch self
                {
                case .Operand(let operand): return "\(operand)"
                case .UnaryOperation(let symbol,_):  return symbol
                case .BinaryOperation(let symbol,_): return symbol
                case .Variable(let symbol): return symbol
                case .NullaryOperation(let symbol, _): return symbol
                }
            }
        }
    }
    var description: String {
        get{
          var (result, ops) = ("", opStack)
            do {
                var current: String?
                (current, ops) = description(ops)
                result = result == "" ? current! : "\(current), \(result)"
            }while ops.count > 0
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):return (String(format: "%g", operand), remainingOps)
            case .NullaryOperation(let symbol, _): return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operationEvaluation = description(remainingOps)
                if var operand = operationEvaluation.result{ return ("\(symbol)(\(operand))", operationEvaluation.remainingOps) }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result{
                    if remainingOps.count - op1Evaluation.remainingOps.count > 2 {
                        operand1 = "\(operand1)"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol): return (symbol, remainingOps)
            }
        }
        return("?", ops)
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    var variableValues = [String:Double]()
    

    
    init(){ //when calculator brain is created
       
        knownOps["*"] = Op.BinaryOperation("*", {$0 * $1})
        knownOps["+"] = Op.BinaryOperation("+", {$0 + $1})
        knownOps["/"] = Op.BinaryOperation("/", {$1 * $0})
        knownOps["-"] = Op.BinaryOperation("-", {$1 - $0})
        knownOps["sqrt"] = Op.UnaryOperation("sqrt", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["π"] = Op.NullaryOperation("π", {M_PI})
        
    }
    
   private func makeOpposite (value: Double) -> Double{
        
        if (!value.isSignMinus){
            return -value
        }
        else{
            return abs(value)
        }
    }
    // implement later , not working 
    func makeLastOpposite() {
        if !opStack.isEmpty{
            var remainingOps = opStack
            let op = remainingOps.removeLast()
            switch(op){
            case .Operand (let operand):
                opStack.removeLast()
                pushOperand(makeOpposite(operand))
            default: break
            }
        }
    }
    
    
    
    func clear (){ opStack.removeAll(keepCapacity: false) }
    
    func evaluate() -> Double? {
        let (result,_) = evaluate(opStack)
        return result
    }
    
    
    private func evaluate (ops: [Op]) -> ( result : Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch(op)
            {
            case .Operand(let operand): return(operand, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps);
                if let operand = operandEvaluation.result {return (operation(operand), operandEvaluation.remainingOps)}
                
            case .BinaryOperation(_, let operation):
               let op1Evaluation = evaluate(remainingOps)
               if let operand1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return (operation(operand1,operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
            case .NullaryOperation(_, let operation): return (operation(), remainingOps)
            }
        }
        return (nil, ops)
    }
    
    
    func pushOperand (operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand (symbol:String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    func performOperation(symbol: String)-> Double?{
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
}


