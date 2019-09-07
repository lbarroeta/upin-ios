//
//  BiographyVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class BiographyVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mainProfileImage: UIImageView!
    @IBOutlet weak var biographyTextField: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        fetchCurrentUserProfileImage()
        biographyTextField.delegate = self
        
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let biography = biographyTextField.text, !biography.isEmpty else {
            simpleAlert(title: "Error", msg: "Must complete your biography...")
            return
        }
        
        updateBiographyOnFirebase()

    }
    
    
    func updateBiographyOnFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }
        var userData = [String: Any]()
        userData = [
            "biography": biographyTextField.text!
        ]
        
        Firestore.firestore().collection("users").document(currentUser.uid).updateData(userData) { (error) in
            if let error = error {
                self.authErrorHandle(error: error)
                print(error.localizedDescription)
                return
            }
            
        }
    }
    
    func fetchCurrentUserProfileImage() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Firestore.firestore().collection("users").document(currentUser.uid).getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            let profileImagePath = data["profilePictures"] as? [String: Any]
            guard let mainProfileImagePath = profileImagePath?["mainProfileImage"] as? String else { return }
            guard let mainProfileImageURL = URL(string: mainProfileImagePath) else { return }
            self.mainProfileImage.kf.setImage(with: mainProfileImageURL)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        numberLabel.text = "\(0 + updateText.count)"
        return updateText.count < 300
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
