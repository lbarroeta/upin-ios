//
//  SignUpVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()

    
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text,
            let password = passwordTextField.text, !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty else {
                simpleAlert(title: "Error", msg: "Must complete all fields to advance...")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.authErrorHandle(error: error)
                return
            }
            
            self.createUserOnFirebase()
            
        }
        
    }
    
    
    func createUserOnFirebase() {
        guard let user = Auth.auth().currentUser else { return }
        guard let email = emailTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text,
        let password = passwordTextField.text, !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty else {
            simpleAlert(title: "Error", msg: "Must complete all fields to advance...")
            return
        }
        
        var userData = [String: Any]()
        userData = [
            "id": user.uid,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "created_at": Timestamp()
        ]
        
        Firestore.firestore().collection("users").document(user.uid).setData(userData) { (error) in
            if let error = error {
                self.authErrorHandle(error: error)
                return
            }
        }
        
        
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
