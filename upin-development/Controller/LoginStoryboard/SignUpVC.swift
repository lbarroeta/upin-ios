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
//        guard let email = emailTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text,
//            let password = passwordTextField.text, !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty else {
//                simpleAlert(title: "Error", msg: "Must complete all fields to advance...")
//                return
//        }
//
//        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
//            if let error = error {
//                self.authErrorHandle(error: error)
//                return
//            }
//            self.createUserOnFirebase()
//        }
        
        
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text,
        let phoneNumber = phoneNumberTextField.text, let password = passwordTextField.text, !firstName.isEmpty,
        !lastName.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, !password.isEmpty else {
            simpleAlert(title: "Error", msg: "Must complete all fields to advance...")
            return
        }
        
        guard let userPhoneNumber = phoneNumberTextField.text else { return }
        
        
        PhoneAuthProvider.provider().verifyPhoneNumber(userPhoneNumber, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                self.authErrorHandle(error: error)
                print(error.localizedDescription)
                return
            }
            
            guard let verifiedId = verificationId else { return }
    
            self.userDefault.set(verifiedId, forKey: "verificationId")
            self.userDefault.synchronize()
            self.userPhoneNumber = self.phoneNumberTextField.text!
            self.performSegue(withIdentifier: "testSegue", sender: self)
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! PhoneCodeVC
        vc.userPhoneNumber = self.userPhoneNumber
    }
    
//    @IBAction func verifyCodePressed(_ sender: Any) {
//
//        guard let otpCode = phoneCodeTextField.text else { return }
//        guard let verificationId = userDefault.string(forKey: "verificationId") else { return }
//
//
//        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: otpCode)
//
//        Auth.auth().signInAndRetrieveData(with: credential) { (success, error) in
//            if let error = error {
//                self.authErrorHandle(error: error)
//                print(error.localizedDescription)
//            }
//
//            self.presentHomeStoryboard()
//        }
//
//    }
    
    fileprivate func presentHomeStoryboard() {
        let storyboard = UIStoryboard(name: Storyboards.HomeStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: HomeViewControllers.HomeVC)
        present(controller, animated: true, completion: nil)
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
