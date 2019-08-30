//
//  SignInVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class SignInVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }
    

    @IBAction func signInButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            simpleAlert(title: "Error", msg: "Must complete the fields to advance...")
            return
        }
        
        signInButton.animateButton(shouldLoad: true, withMessage: nil)
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.signInButton.animateButton(shouldLoad: false, withMessage: "Sign in")
                self.authErrorHandle(error: error)
                return
            }
            
            self.presentHomeStoryboard()
        }
        
        
    }
    
    fileprivate func presentHomeStoryboard() {
        let storyboard = UIStoryboard(name: Storyboards.HomeStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: HomeViewControllers.HomeVC)
        present(controller, animated: true, completion: nil)
    }
    
    
}
