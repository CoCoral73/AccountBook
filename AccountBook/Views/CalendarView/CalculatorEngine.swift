//
//  CalculatorEngine.swift
//  AccountBook
//
//  Created by 김정원 on 12/16/25.
//
import Foundation

final class CalculatorEngine {

    private var currentValue: Decimal = 0
    private var pendingOperator: Operator?
    private var buffer: Decimal = 0
    private var didJustEvaluate = false

    func input(_ input: NumericKeypadInput) -> Decimal {
        switch input {
        case .number(let n):
            if didJustEvaluate {
                buffer = Decimal(n)
                didJustEvaluate = false
            } else {
                buffer = buffer * 10 + Decimal(n)
            }
        case .operatorType(let op):
            applyPending()
            if op == .equal {
                pendingOperator = nil
                didJustEvaluate = true
            } else {
                pendingOperator = op
                didJustEvaluate = false
            }
        case .delete:
            buffer = buffer / 10
            buffer = Decimal(Int(truncating: NSDecimalNumber(decimal: buffer)))
        case .allClear:
            reset()
        }
        return buffer != 0 ? buffer : currentValue
    }

    private func applyPending() {
        guard let op = pendingOperator else {
            if !didJustEvaluate {
                currentValue = buffer
            }
            buffer = 0
            return
        }

        switch op {
        case .add:
            currentValue += buffer
        case .subtract:
            currentValue -= buffer
        case .multiply:
            currentValue *= buffer
        case .divide:
            currentValue /= buffer
        default:
            break
        }
        
        var rounded = Decimal()
        NSDecimalRound(&rounded, &currentValue, 0, .down)
        currentValue = rounded
        
        buffer = 0
    }

    private func reset() {
        currentValue = 0
        buffer = 0
        pendingOperator = nil
    }
}
