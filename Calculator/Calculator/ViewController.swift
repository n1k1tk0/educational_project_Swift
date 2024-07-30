import UIKit

class ViewController: UIViewController {
    
    // flag определяет продолжать печать операнда или начать заново
    var flag = true {
        
        // наблюдатель определяет в какой операнд записывать введенное значение
        didSet {
            if oldValue == false {
                if valueOne == "" {
                    valueOne = resultLabel.text!
                } else {
                    valueTwo = resultLabel.text!
                }
            }
        }
    }
    
    // flagOfType предназначен для корректного ввода числа с плавающей точкой
    var flagOfType = true
    
    var selectedMathOperation: MathOperations? {
        didSet { previousSelectedMathOperation = oldValue }
    }
    
    var previousSelectedMathOperation: MathOperations?
    var valueOne = ""
    var valueTwo = ""
    // переменная предназначена для повторения выбранной операции с фиксированным правым операндом через оператор присваивания
    var valueRepeat = ""

    @IBOutlet weak var resultLabel: UILabel!
    
    // метод выводит нажатые цифры в лейбл
    @IBAction func numberButton(_ sender: UIButton) {
        if flag {
            if sender.titleLabel!.text == "+/-" && resultLabel.text!.first != "-" {
                resultLabel.text! = "-" + resultLabel.text!
                valueOne = resultLabel.text!
            } else if sender.titleLabel!.text == "+/-" && resultLabel.text!.first == "-" {
                resultLabel.text?.removeFirst()
                valueOne = resultLabel.text!
            } else {
                resultLabel.text = sender.titleLabel!.text!
                flag = false
            }
            if sender.titleLabel!.text == "," {
                resultLabel.text! = "0" + sender.titleLabel!.text!
                flagOfType = false
            }
        } else {
            if sender.titleLabel!.text == "+/-" && resultLabel.text!.first == "-" {
                resultLabel.text?.removeFirst()
            } else if sender.titleLabel!.text == "+/-" && resultLabel.text!.first != "-" {
                resultLabel.text! = "-" + resultLabel.text!
            } else if sender.titleLabel!.text == "," && flagOfType == true {
                resultLabel.text! += sender.titleLabel!.text!
                flagOfType = false
            } else if sender.titleLabel!.text == "," && flagOfType == false {
            } else {
                resultLabel.text! += sender.titleLabel!.text!
            }
        }
    }
    
    
    @IBAction func operationsButton(_ sender: UIButton) {
        flag = true
        flagOfType = true
        switch sender.titleLabel!.text! {
            case "+":
            selectedMathOperation = .addition
            valueOne = resultLabel.text!
            if previousSelectedMathOperation == selectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(selectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            } else if previousSelectedMathOperation != nil && selectedMathOperation != previousSelectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(previousSelectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            }
            valueTwo = ""
            valueRepeat = valueOne
            case "-":
            selectedMathOperation = .subtraction
            valueOne = resultLabel.text!
            if previousSelectedMathOperation == selectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(selectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            } else if previousSelectedMathOperation != nil && selectedMathOperation != previousSelectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(previousSelectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            }
            valueTwo = ""
            valueRepeat = valueOne
            case "X":
            selectedMathOperation = .multiplication
            valueOne = resultLabel.text!
            if previousSelectedMathOperation == selectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(selectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            } else if previousSelectedMathOperation != nil && selectedMathOperation != previousSelectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(previousSelectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            }
            valueTwo = ""
            valueRepeat = valueOne
            case "/":
            selectedMathOperation = .division
            valueOne = resultLabel.text!
            if previousSelectedMathOperation == selectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(selectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            } else if previousSelectedMathOperation != nil && selectedMathOperation != previousSelectedMathOperation && valueTwo != "" {
                resultLabel.text! = String(previousSelectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
            }
            valueTwo = ""
            valueRepeat = valueOne
            case "=":
            if valueTwo == "" && selectedMathOperation != nil {
                resultLabel.text! = String(selectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueRepeat))
                valueOne = resultLabel.text!
            } else if selectedMathOperation != nil {
                resultLabel.text! = String(selectedMathOperation!.evaluate(leftOperand: &valueOne, rightOperand: &valueTwo))
                valueOne = resultLabel.text!
                valueRepeat = valueTwo
            }
            valueTwo = ""
            default:
            break
        }
    }
    
    // только кнопка сброса: АС
    @IBAction func clearButton(_ sender: UIButton) {
        flag = true
        flagOfType = true
        selectedMathOperation = nil
        previousSelectedMathOperation = nil
        resultLabel.text = "0"
        valueOne = ""
        valueTwo = ""
        valueRepeat = ""
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
