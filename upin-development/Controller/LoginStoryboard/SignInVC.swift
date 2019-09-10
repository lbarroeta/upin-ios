//
//  SignInVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SignInVC: UIViewController {

    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var signInButton: ActionButton!
    
    let userDefault = UserDefaults.standard
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }
    

    @IBAction func signInButtonPressed(_ sender: Any) {
        guard let phone = phoneNumberTextField.text, !phone.isEmpty else {
            simpleAlert(title: "Error", msg: "Must provide a phone number to advance...")
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
                self.performSegue(withIdentifier: "SignInPhoneCodeVC", sender: self)
            })
            
            self.hud.textLabel.text = "Loading"
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 4.0, animated: true)
            
        }, handlerCancel: nil)
        
        
        
    }
    
}
