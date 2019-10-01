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
 

    var indexPath: IndexPath?
    
    @IBOutlet weak var profilePicture: RoundedImage!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageNumberLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var connectionsCounterLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var interests = [Interests]()
    var listener: ListenerRegistration!
    
    var interestNames = [String]()
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileListener()
        userConnectionsListener()
        
        hud.textLabel.text = "Loading your information"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.5, animated: true)

    }
    
    @IBAction func connectionsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ConnectionsVC", sender: self)
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "EditUserProfileVC", sender: self)
    }
    
    func userProfileListener() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserReference = Firestore.firestore().collection("users").document(currentUser.uid)
        
        currentUserReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            self.interestNames = data["interests"] as? Array ?? [""]
            self.collectionView.reloadData()
            
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let biography = data["biography"] as? String ?? ""
            let gender = data["gender"] as? String ?? ""
            let birthdate = data["birthdate"] as? String ?? ""
            
            
            // Set profile image
            let profileImagePath = data["profilePictures"] as? [String: Any]
            guard let mainProfileImagePath = profileImagePath?["mainProfileImage"] as? String else { return }
            guard let mainProfileImageURL = URL(string: mainProfileImagePath) else { return }
            
            // Get age from user
            let stringBirthdate: String = birthdate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let date = dateFormatter.date(from: stringBirthdate)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: date!)
            let now = Date()
            let finalYear = calendar.date(from: components)
            let age = calendar.dateComponents([.year], from: finalYear!, to: now)
            
            self.profilePicture.kf.setImage(with: mainProfileImageURL)
            self.firstNameLabel.text = firstName
            self.lastNameLabel.text = lastName
            self.biographyLabel.text = biography
            self.genderLabel.text = gender
            self.ageNumberLabel.text = "\(age.year!)"
            
        }
        
    }
    
    func userConnectionsListener() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        listener = Firestore.firestore().collection("users").document(currentUser.uid).collection("connections").addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            let counter = snapshot?.count
            self.connectionsCounterLabel.text = String(counter!)
        })
    }
}

extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interestNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileInterestsCell", for: indexPath) as! ProfileInterestsCell
        cell.interestsLabel.text = interestNames[indexPath.item]

       
        if indexPath.item == 0 {
            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
            cell.counterBackgroundView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.counterBackgroundView.layer.cornerRadius = 10
            
            cell.counterBackgroundView.isHidden = false
            
            cell.interestsCountLabel.textColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsCountLabel.text = "1"
        } else if indexPath.item == 1 {
            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
            cell.counterBackgroundView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.counterBackgroundView.layer.cornerRadius = 10
            
            cell.counterBackgroundView.isHidden = false
            cell.interestsCountLabel.textColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsCountLabel.text = "2"
        } else if indexPath.item == 2 {

            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

            cell.counterBackgroundView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.counterBackgroundView.layer.cornerRadius = 10
            
            cell.counterBackgroundView.isHidden = false
            cell.interestsCountLabel.textColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsCountLabel.text = "3"
            
        } else if 3...7 ~= indexPath.item {
            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.interestsLabel.textColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.counterBackgroundView.isHidden = true
        }
        
        return cell
    }
    

}

