//
//  ProfileVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/29/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import JGProgressHUD

class ProfileVC: UIViewController {

    @IBOutlet weak var profilePicture: RoundedImage!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageNumberLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileListener()
        
        hud.textLabel.text = "Loading your information"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.5, animated: true)
        
    }
    
    func userProfileListener() {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Firestore.firestore().collection("users").document(currentUser.uid).getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let gender = data["gender"] as? String ?? ""
            let birthdate = data["birthdate"] as? String ?? ""
            let biography = data["biography"] as? String ?? ""
            
            let profileImagePath = data["profilePictures"] as? [String: Any]
            guard let mainProfileImagePath = profileImagePath?["mainProfileImage"] as? String else { return }
            guard let mainProfileImageURL = URL(string: mainProfileImagePath) else { return }
            self.profilePicture.kf.setImage(with: mainProfileImageURL)
            
            let stringBirthdate: String = birthdate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let date = dateFormatter.date(from: stringBirthdate)
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: date!)
            let now = Date()
            let finalYear = calendar.date(from: components)
            let age = calendar.dateComponents([.year], from: finalYear!, to: now)
            
            
            self.firstNameLabel.text = firstName
            self.lastNameLabel.text = lastName
            self.genderLabel.text = gender
            self.biographyLabel.text = biography
            self.ageNumberLabel.text = "\(age.year!)"
        }
    }
    
}
