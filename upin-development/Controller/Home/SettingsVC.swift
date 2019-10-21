//
//  SettingsVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/29/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        self.signOutAlert(title: "Logout", msg: "You will be returned to the sign in screen", handlerOK: { action in
            do {
                try Auth.auth().signOut()
                UserService.signOutUser()
                self.presentLoginStoryboard()
            } catch let error {
                self.authErrorHandle(error: error)
            }
        }, handlerCancel: { actionCancel in
            print("Cancel Action")
        })
        
    }
    
    @IBAction func accountButtonPressed(_ sender: Any) {
        presentAccountVC()
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
        presentPrivacyPolicyVC()
    }
    
    @IBAction func helpButtonPressed(_ sender: Any) {
        presentHelpVC()
    }
    
    
    fileprivate func presentAccountVC() {
        let storyboard = UIStoryboard(name: Storyboards.SettingsStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: SettingsViewControllers.AccountVC)
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func presentPrivacyPolicyVC() {
        let storyboard = UIStoryboard(name: Storyboards.SettingsStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: SettingsViewControllers.PrivacyPolicyVC)
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func presentHelpVC() {
        let storyboard = UIStoryboard(name: Storyboards.SettingsStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: SettingsViewControllers.HelpVC)
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func presentLoginStoryboard(){
        let storyboard = UIStoryboard(name: Storyboards.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: LoginViewControllers.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
}


