import Foundation

extension Double {
    // вычисляемое свойство для отсечения остатка, если используются инт значения и округления до 6 чисел после запятой
    var remainderClipping: String {
        var resultOfArray = String(self).components(separatedBy: ".")
        
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(self))
        } else {
            if resultOfArray[1].count > 5 {
                resultOfArray[1].removeSubrange((resultOfArray[1].index(resultOfArray[1].startIndex, offsetBy: 7))..<resultOfArray[1].index(before: resultOfArray[1].endIndex))
                return resultOfArray[0] + "." + resultOfArray[1]
            } else {
                return String(self)
            }
        }
     }
}

enum MathOperations {
    case addition
    case subtraction
    case multiplication
    case division
    
    // основной вычислительный метод
    func evaluate(leftOperand: inout String, rightOperand: inout String) -> String {
        var result: Double
        
        // циклы заменяют символ "," на "." для корректности вычисления
        for (index, value) in leftOperand.enumerated() {
            if value == "," {
                leftOperand.remove(at: leftOperand.index(leftOperand.startIndex, offsetBy: index))
                leftOperand.insert(".", at: leftOperand.index(leftOperand.startIndex, offsetBy: index))
            }
        }
        
        for (index, value) in rightOperand.enumerated() {
            if value == "," {
                rightOperand.remove(at: rightOperand.index(rightOperand.startIndex, offsetBy: index))
                rightOperand.insert(".", at: rightOperand.index(rightOperand.startIndex, offsetBy: index))
            }
        }
        
        // условие улавливает попытку деления на ноль и выводит сообщение, иначе происходит вычисление
        if (rightOperand == "0" || rightOperand == "0.") && self == .division {
            return ErrorMessages.divisionByZero.rawValue
        } else {
            switch self {
            case .addition:
                result = Double(leftOperand)! + Double(rightOperand)!
            case .subtraction:
                result = Double(leftOperand)! - Double(rightOperand)!
            case .multiplication:
                result = Double(leftOperand)! * Double(rightOperand)!
            case .division:
                result = Double(leftOperand)! / Double(rightOperand)!
            }
        }
        
        // блок заменяет символ "." на "," для корректности отображения на экране
        var resultOfString = String(result.remainderClipping)
        for (index, value) in resultOfString.enumerated() {
            if value == "." {
                resultOfString.remove(at: resultOfString.index(resultOfString.startIndex, offsetBy: index))
                resultOfString.insert(",", at: resultOfString.index(resultOfString.startIndex, offsetBy: index))
            }
        }
        return resultOfString
    }
}
