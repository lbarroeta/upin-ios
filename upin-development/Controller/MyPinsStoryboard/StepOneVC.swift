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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
//        guard let title = pinTitleTextField.text, let description = shortDescriptionTextField.text, !title.isEmpty, !description.isEmpty else {
//            self.simpleAlert(title: "Error", msg: "Must complete the fields to advance..")
//            return
//        }
        
        self.performSegue(withIdentifier: "ToStepTwoVC", sender: self)
    }
    
    func createPinOnFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard let title = pinTitleTextField.text, let description = shortDescriptionTextField.text, !title.isEmpty, !description.isEmpty else {
            simpleAlert(title: "Error", msg: "Must complete the fields to advance..")
            return
        }
        
        var pinData = [String: Any]()
        pinData = [
            "host_id": currentUser.uid,
            "pin_title": pinTitleTextField.text!,
            "short_description": shortDescriptionTextField.text!
        ]
        
        Firestore.firestore().collection("pins").document().setData(pinData) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "ToStepTwoVC", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! StepTwoVC
        vc.pin_title = self.pinTitleTextField.text!
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
