//
//  KeyboardViewController.swift
//  KemBoard
//
//  Created by Daniel Kwiatkowski on 2015-06-23.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import UIKit

enum Operation{
    case Addition
    case Multiplication
    case Subtraction
    case Division
    case None
}



class KeyboardViewController: UIInputViewController {
    //stores the temporary result
    var internalMemory = 0.0
    //this property stores the next operation
    var nextOperation = Operation.None
    //another one that to remember if it should apply the nextOperation after an operation is pressed
    var shouldCompute = false

    var shouldClearDisplayBeforeInserting = true
    
    @IBOutlet var abcButton: UIButton!
    
    var calculatorView: UIView!
    
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var display:UILabel!

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInterface()
        clearDisplay()
        
        
//        let buttonTitles = ["Qr", "W","E","R","T","Y","U","I","O","P"];
//        var buttons = [UIButton]()
//        var keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
//        
//        for buttonTitle in buttonTitles{
//            let button = createButtonWithTitle(buttonTitle)
//            buttons.append(button)
//            keyboardRowView.addSubview(button)
//        }
//        
//        
//        self.view.addSubview(keyboardRowView)
//        addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
//        
//        // Perform custom UI setup here
//        self.abcButton = UIButton.buttonWithType(.System) as! UIButton
//        let button = createButtonWithTitle("Br")
//    
//        self.abcButton.setTitle(NSLocalizedString("ABC", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
//        self.abcButton.sizeToFit()
//        self.abcButton.setTranslatesAutoresizingMaskIntoConstraints(false)
//    
//        self.abcButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
//
//        self.view.addSubview(self.abcButton)
//    
//        var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.abcButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
//        var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.abcButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
//        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])
        
        
    }
    
    
    
    
    func loadInterface(){
        //load the nib file
        var calculatorNib = UINib(nibName: "Keyboard", bundle: nil)
        //instantiate your view
        calculatorView = calculatorNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        calculatorView.frame = self.view.bounds
        //add the interface to the main view
        view.addSubview(calculatorView)
        // copr the background color
        view.backgroundColor = calculatorView.backgroundColor
        
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        
    }
    
    
    @IBAction func clearDisplay(){
        display.text = "0"
        internalMemory = 0
        nextOperation = Operation.Addition
        shouldClearDisplayBeforeInserting = true
    }

    
    @IBAction func didTapNumber(number: UIButton){
        if shouldClearDisplayBeforeInserting{
            display.text = ""
            shouldClearDisplayBeforeInserting = false
        }
        
        if var numberAsString = number.titleLabel?.text {
            var numberAsNSString = numberAsString as NSString
            if var oldDisplay = display?.text!{
                display.text = "\(oldDisplay)\(numberAsNSString.intValue)"
            } else{
                display.text = "\(numberAsNSString.intValue)"
            }
        }
    }
    
    @IBAction func didTapDot(){
        if let input = display?.text{
            var hasDot = false
            for ch in input.unicodeScalars{
                if ch == "."{
                    hasDot = true
                    break
                }
            }
            if hasDot == false{
                display.text = "\(input)."
            }
        }
    }
    
    
    @IBAction func didTapInsert(){
        var proxy = textDocumentProxy as! UITextDocumentProxy
        
        if let input = display?.text as String?{
            proxy.insertText(input)
        }
    }
    
    @IBAction func didTapOperation(operation:UIButton){
        if shouldCompute{
            computeLastOperation()
        }
        
        if var op = operation.titleLabel?.text{
            switch op{
            case "+":
                nextOperation = Operation.Addition
            case "-":
                nextOperation = Operation.Subtraction
            case "X":
                nextOperation = Operation.Multiplication
            case "%":
                nextOperation = Operation.Division
            default:
                nextOperation = Operation.None
            }
        }
    }
    
    
    
    
    @IBAction func computeLastOperation(){
        
        //do not compute if another operation is pressed without inputing another number first
        shouldCompute = false
        
        if var input = display?.text{
            var inputAsDouble = (input as NSString).doubleValue
            var result = 0.0
            
            //apply the operation
            switch nextOperation{
            case .Addition:
                result = internalMemory + inputAsDouble
            case .Subtraction:
                result = internalMemory - inputAsDouble
            case .Multiplication:
                result = internalMemory * inputAsDouble
            case .Division:
                result = internalMemory / inputAsDouble
            default:
                result = 0.0
            }
            
            nextOperation = Operation.None
            
            var output = "\(result)"
            
            if output.hasSuffix(".0"){
                output = "\(Int(result))"
            }
            
            //truncating the last five digits
            var components = output.componentsSeparatedByString(".")
            if components.count >= 2{
                var beforePoint = components[0]
                var afterPoint = components[1]
                if afterPoint.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 5{
                    let index: String.Index = advance(afterPoint.startIndex,5)
                    afterPoint = afterPoint.substringToIndex(index)
                }
                output = beforePoint + "." + afterPoint
            }
            //update the display
            display.text = output
            
            //save the result
            internalMemory = result
            
            //remember to clear the display before  inserting a new number
            shouldClearDisplayBeforeInserting = true
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

//    override func textDidChange(textInput: UITextInput) {
//        // The app has just changed the document's contents, the document context has been updated.
//    
//        var textColor: UIColor
//        var proxy = self.textDocumentProxy as! UITextDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
//            textColor = UIColor.whiteColor()
//        } else {
//            textColor = UIColor.blackColor()
//        }
//        self.abcButton.setTitleColor(textColor, forState: .Normal)
//    }
// 
//    func createButtonWithTitle(title:String) -> UIButton{
//        let button = UIButton.buttonWithType(.System) as! UIButton
//        button.frame = CGRectMake(0, 0, 40, 40)
//        button.setTitle(title, forState: .Normal)
//        button.sizeToFit()
//        button.titleLabel?.font = UIFont.systemFontOfSize(15)
//        button.setTranslatesAutoresizingMaskIntoConstraints(false)
//        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
//        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
//        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
//        return button
//    }
//    
//    func didTapButton(sender:AnyObject?){
//        let button = sender as! UIButton
//        let title = button.titleForState(.Normal)
//        var proxy = textDocumentProxy as! UITextDocumentProxy
//            proxy.insertText(title!)
//
//    }

    //add constraints to prevent the overlapping of keyboard array buttons
//    func addIndividualButtonConstraints(buttons:[UIButton], mainView:UIView){
//        
//        for (index, button) in enumerate(buttons){
//            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
//            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -1)
//            var rightConstraint:NSLayoutConstraint!
//            
//            if index == buttons.count - 1 {
//                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -1)
//            } else{
//                let nextButton = buttons[index + 1]
//                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -1)
//            }
//            var leftConstraint:NSLayoutConstraint!
//            if index == 0 {
//                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 1)
//            } else{
//                let prevtButton = buttons[index - 1]
//                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 1)
//                let firstButton = buttons[0]
//                var widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
//            }
//            mainView.addConstraints([topConstraint,rightConstraint,leftConstraint])
//            
//        }
//    }
}
