//
//  UserJoinedProfileVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/30/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class UserJoinedProfileVC: UIViewController {
    
    @IBOutlet weak var profileImage: RoundedImage!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var selectedUser: UserJoined!
    var interestNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        
        setupCollectionView()
        userListener()

        self.firstNameLabel.text = selectedUser.firstName
        self.lastNameLabel.text = selectedUser.lastName
        self.genderLabel.text = selectedUser.gender
        self.ageLabel.text = String(selectedUser.age)
        
        guard let profileImageURL = URL(string: selectedUser.profileImage) else { return }
        self.profileImage.kf.setImage(with: profileImageURL)
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    

    @IBAction func joinedButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func userListener() {
        let userReference = Firestore.firestore().collection("users").document(selectedUser.user_id)
        userReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            self.interestNames = data["interests"] as? Array ?? [""]
            self.collectionView.reloadData()
        }
    }
    
}

extension UserJoinedProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interestNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserJoinedProfileInterestsCell", for: indexPath) as! UserJoinedProfileInterestsCell
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
