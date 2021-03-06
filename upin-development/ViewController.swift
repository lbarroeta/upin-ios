//
//  ViewController.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: Storyboards.LoginStoryboard, bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: LoginViewControllers.LoginVC)
            present(controller, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: Storyboards.HomeStoryboard, bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: HomeViewControllers.HomeVC)
            present(controller, animated: true, completion: nil)
        }
    }
}

