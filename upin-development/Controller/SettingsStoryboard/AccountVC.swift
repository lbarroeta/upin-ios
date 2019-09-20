//
//  AccountVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/9/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class AccountVC: UIViewController {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    var email = [User]()
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userListener()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
    }
    
    func userListener() {
        guard let currentUser = Auth.auth().currentUser else { return }
        listener = Firestore.firestore().collection("users").document(currentUser.uid).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            let phone_number = data["phone_number"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            
            self.phoneNumberLabel.text = phone_number
            self.emailLabel.text = email
            
        })
    }
    
}

