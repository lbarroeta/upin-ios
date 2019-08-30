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

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        self.signOutAlert(title: "Logout", msg: "You will be returned to the sign in screen", handlerOK: { action in
            do {
                try Auth.auth().signOut()
                self.presentLoginStoryboard()
            } catch let error {
                self.authErrorHandle(error: error)
            }
        }, handlerCancel: { actionCancel in
            print("Cancel Action")
        })
        
    }
    
    fileprivate func presentLoginStoryboard(){
        let storyboard = UIStoryboard(name: Storyboards.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: LoginViewControllers.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
}


