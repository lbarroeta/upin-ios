//
//  StepOneVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class StepOneVC: UIViewController {

    @IBOutlet weak var pinTitleTextField: UITextField!
    @IBOutlet weak var pinTitleCounterLabel: UILabel!
    @IBOutlet weak var shortDescriptionTextField: UITextView!
    @IBOutlet weak var shortDescriptionCounterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shortDescriptionTextField.delegate = self
        pinTitleTextField.delegate = self
        
        shortDescriptionTextField.text = "Short description"
        shortDescriptionTextField.textColor = UIColor.lightGray
        
        
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let title = pinTitleTextField.text, let description = shortDescriptionTextField.text, shortDescriptionTextField.text != "Short description", !title.isEmpty, !description.isEmpty else {
            self.simpleAlert(title: "Error", msg: "Must complete the fields to advance..")
            return
        }
        
        self.performSegue(withIdentifier: "ToStepTwoVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! StepTwoVC
        vc.pin_title = self.pinTitleTextField.text!
        vc.short_description = self.shortDescriptionTextField.text!
    }
        
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}



extension StepOneVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: text)
        shortDescriptionCounterLabel.text = "\(0 + updateText.count)"
        return updateText.count < 300
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if shortDescriptionTextField.textColor == UIColor.lightGray {
            shortDescriptionTextField.text = nil
            shortDescriptionTextField.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: 335, height: .max)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
    }
    
}

extension StepOneVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        pinTitleCounterLabel.text = "\(0 + updateText.count)"
        return updateText.count < 35
    }
}
