//
//  PhoneCodeVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/31/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class PhoneCodeVC: UIViewController {
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var firstNumberTextField: UITextField!
    @IBOutlet weak var secondNumberTextField: UITextField!
    @IBOutlet weak var thirdNumberTextField: UITextField!
    @IBOutlet weak var fourNumberTextField: UITextField!
    @IBOutlet weak var fifthNumberTextField: UITextField!
    @IBOutlet weak var sixNumberTextField: UITextField!
    
    let userDefault = UserDefaults.standard
    
    var finalUserId = ""
    var userPhoneNumber = ""
    var users = [User]()
    var firstName = ""
    var lastName = ""
    var email = ""
    var create_at = Timestamp()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        phoneNumberLabel.text = userPhoneNumber
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        guard let firstTextField = firstNumberTextField.text, let secondTextField = secondNumberTextField.text, let thirdTextField = thirdNumberTextField.text,
        let fourTextField = fourNumberTextField.text, let fifthTextField = fifthNumberTextField.text, let sixTextField = sixNumberTextField.text, !firstTextField.isEmpty,
        !secondTextField.isEmpty, !thirdTextField.isEmpty, !fourTextField.isEmpty, !fifthTextField.isEmpty, !sixTextField.isEmpty else {
            simpleAlert(title: "Error", msg: "Must correctly introduce the code to advance...")
            return
        }
        
        let verificationCode: String = "\(firstTextField)\(secondTextField)\(thirdTextField)\(fourTextField)\(fifthTextField)\(sixTextField)"
        
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "verificationID")!, verificationCode: verificationCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (success, error) in
            if let error = error {
                self.authErrorHandle(error: error)
                print(error.localizedDescription)
            }
            
            self.performSegue(withIdentifier: "GenderAndBirthdayVC", sender: self)
            self.createUserOnFirebase()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    func createUserOnFirebase() {
        guard let user = Auth.auth().currentUser else { return }
        
        var userData = [String: Any]()
        userData = [
            "id": user.uid,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone_number": userPhoneNumber,
            "created_at": Timestamp(),
            "register_complete": false
        ]
        
        Firestore.firestore().collection("users").document(user.uid).setData(userData) { (error) in
            if let error = error {
                self.authErrorHandle(error: error)
                return
            }
        }
    }
    
    
    @IBAction func resendCodeButtonPressed(_ sender: Any) {
        guard let phoneNumber = phoneNumberLabel.text else { return }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                self.authErrorHandle(error: error)
                print(error.localizedDescription)
                return
            }
            
            guard let verifiedId = verificationId else { return }
            self.userDefault.set(verifiedId, forKey: "verificationId")
            
            
        }
        
    }
    
}
