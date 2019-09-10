//
//  SignInPhoneCodeVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/9/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class SignInPhoneCodeVC: UIViewController {

    @IBOutlet weak var firstNumberTextField: UITextField!
    @IBOutlet weak var secondNumberTextField: UITextField!
    @IBOutlet weak var thirdNumberTextField: UITextField!
    @IBOutlet weak var fourNumberTextField: UITextField!
    @IBOutlet weak var fifthNumberTextField: UITextField!
    @IBOutlet weak var sixthNumberTextField: UITextField!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let firstNumber = firstNumberTextField.text, let secondNumber = secondNumberTextField.text, let thirdNumber = thirdNumberTextField.text, let fourNumber = fourNumberTextField.text, let fifthNumber = fifthNumberTextField.text,
        let sixthNumber = sixthNumberTextField.text, !firstNumber.isEmpty, !secondNumber.isEmpty, !thirdNumber.isEmpty, !fourNumber.isEmpty, !fifthNumber.isEmpty, !sixthNumber.isEmpty else {
            simpleAlert(title: "Error", msg: "Must correctly introduce the code to advance...")
            return
        }
        
        let verificationCode: String = "\(firstNumber)\(secondNumber)\(thirdNumber)\(fourNumber)\(fifthNumber)\(sixthNumber)"
        
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "verificationID")!, verificationCode: verificationCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (success, error) in
            if let error = error {
                self.authErrorHandle(error: error)
                print(error.localizedDescription)
            }
            
            self.presentHomeStoryboard()
        }
        
    }
    
    @IBAction func resendCodeButtonPressed(_ sender: Any) {
        
    }
    
    fileprivate func presentHomeStoryboard() {
        let storyboard = UIStoryboard(name: Storyboards.HomeStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: HomeViewControllers.HomeVC)
        present(controller, animated: true, completion: nil)
    }
}
