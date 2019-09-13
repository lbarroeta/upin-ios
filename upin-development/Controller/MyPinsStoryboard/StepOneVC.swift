//
//  StepOneVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class StepOneVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var pinTitleTextField: UITextField!
    @IBOutlet weak var shortDescriptionTextField: UITextField!
    @IBOutlet weak var shortDescriptionCounterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shortDescriptionTextField.delegate = self
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let title = pinTitleTextField.text, let description = shortDescriptionTextField.text, !title.isEmpty, !description.isEmpty else {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        shortDescriptionCounterLabel.text = "\(0 + updateText.count)"
        return updateText.count < 300
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
