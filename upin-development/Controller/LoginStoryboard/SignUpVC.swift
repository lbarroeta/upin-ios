//
//  SignUpVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SignUpVC: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UINavigationItem!
    
    let userDefault = UserDefaults.standard
    
    var userId = ""
    var userPhoneNumber = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()

    
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text,
        let phoneNumber = phoneNumberTextField.text, let password = passwordTextField.text, !firstName.isEmpty,
        !lastName.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, !password.isEmpty else {
            simpleAlert(title: "Error", msg: "Must complete all fields to advance...")
            return
        }
        
        
        
        self.signUpAlert(title: "Phone number", msg: "Is this your phone number? \(phoneNumberTextField.text!)", handlerOK: { (action) in
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumberTextField.text!, uiDelegate: nil, completion: { (verificationID, error) in
                if let error = error {
                    self.authErrorHandle(error: error)
                    print(error.localizedDescription)
                    return
                }
                
                self.userDefault.setValue(verificationID, forKey: "verificationID")
                self.performSegue(withIdentifier: "PhoneCodeVC", sender: self)
                
            })
            
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 5.0)
            
            
        }, handlerCancel: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! PhoneCodeVC
        vc.userPhoneNumber = self.phoneNumberTextField.text!
        vc.finalUserId = self.userId
        vc.firstName = self.firstNameTextField.text!
        vc.lastName = self.lastNameTextField.text!
        vc.email = self.emailTextField.text!
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
