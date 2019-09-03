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
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
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

        phoneNumberLabel.text = userPhoneNumber
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
    
        guard let code = codeTextField.text, !code.isEmpty else {
            simpleAlert(title: "Error", msg: "Must introduce code to advance...")
            return
        }
        
        guard let otpCode = codeTextField.text else { return }
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "verificationID")!, verificationCode: otpCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (success, error) in
            if let error = error {
                self.authErrorHandle(error: error)
                print(error.localizedDescription)
            }
            
            self.performSegue(withIdentifier: "GenderAndBirthdayVC", sender: self)
            self.createUserOnFirebase()
            
        }
        
    }
    
    
    func createUserOnFirebase() {
        guard let user = Auth.auth().currentUser else { return }
        
        var userData = [String: Any]()
        userData = [
            "id": user.uid,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
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
    
    fileprivate func presentHomeStoryboard() {
        let storyboard = UIStoryboard(name: Storyboards.HomeStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: HomeViewControllers.HomeVC)
        present(controller, animated: true, completion: nil)
    }
    
}
