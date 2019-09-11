//
//  HelpVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/10/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HelpVC: UIViewController {

    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard let subject = subjectTextField.text, let message = messageTextField.text, !subject.isEmpty, !message.isEmpty else {
            simpleAlert(title: "Error", msg: "Must complete the fields to advance...")
            return
        }
        
        
        var helpData = [String: Any]()
        helpData = [
            "user_id": currentUser.uid,
            "subject": subject,
            "message": message
        ]
        
        self.sendHelpAlert(title: "Verify", msg: "Are you sure to send this?", handlerOk: { (action) in
            Firestore.firestore().collection("reports").document().setData(helpData) { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }, handlerCancel: nil)
        
        
        
        
        
        
    }
    
}
