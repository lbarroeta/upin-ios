//
//  EditUserInterestsVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 10/20/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class EditUserInterestsVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedInterestCountLabel: UILabel!
    @IBOutlet weak var interestCollectionCountLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var interests = [Interests]()
    var listener: ListenerRegistration!
    var selectedInterestsArray = [String]()
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        interestsListener()
        countInterestsListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        interests.removeAll()
        collectionView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.hud.textLabel.text = "Updating your interests..."
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 1.5, animated: true)
        
        self.addInterestsToUsers()
    }
    
    func interestsListener() {
        Firestore.firestore().collection("interests").whereField("is_active", isEqualTo: true).order(by: "name", descending: false).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            snapshot?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let interest = Interests.init(data: data)
                
                switch change.type {
                case .added:
                    self.onInterestAdded(change: change, interest: interest)
                case .modified:
                    self.onInterestModified(change: change, interest: interest)
                case .removed:
                    self.onInterestRemoved(change: change)
                }
            })
        })
    }
    
    func countInterestsListener() {
        Firestore.firestore().collection("interests").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let data = snapshot?.documents.count
            self.interestCollectionCountLabel.text = "\(data!)"
            
        }
    }
    
    func addInterestsToUsers() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserReference = Firestore.firestore().collection("users").document(currentUser.uid)
        
        var userData = [String: Any]()
        
        userData = [
            "interests": selectedInterestsArray
        ]
        
        currentUserReference.updateData(userData) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension EditUserInterestsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func onInterestAdded(change: DocumentChange, interest: Interests) {
        let newIndex = Int(change.newIndex)
        interests.insert(interest, at: newIndex)
        collectionView.insertItems(at: [IndexPath.init(item: newIndex, section: 0)])
    }
    
    func onInterestModified(change: DocumentChange, interest: Interests) {
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            interests[index] = interest
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            interests.remove(at: oldIndex)
            interests.insert(interest, at: newIndex)
            
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onInterestRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        interests.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath.init(item: oldIndex, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditInterestsCell", for: indexPath) as? InterestsCell {
            cell.configureCell(interests: interests[indexPath.item])
            
            if let index = selectedInterestsArray.firstIndex(of: cell.interestsLabel.text!) {
                cell.numberBackgroundView.isHidden = true
                cell.numberLabel.text = "\(index + 1)"
                switch index {
                case 0..<3:
                    cell.numberBackgroundView.isHidden = false
                    cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.9412322044, green: 0.7829019427, blue: 0.1854074299, alpha: 1)
                    cell.numberBackgroundView.backgroundColor = #colorLiteral(red: 0.9636644721, green: 0.9492474198, blue: 0.978384912, alpha: 1)
                    
                case 3..<7:
                    cell.numberBackgroundView.isHidden = false
                    cell.numberBackgroundView.backgroundColor = #colorLiteral(red: 0.9636644721, green: 0.9492474198, blue: 0.978384912, alpha: 1)
                    cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.8666666667, blue: 0.6941176471, alpha: 1)
                    
                default: break
                }
            } else {
                cell.numberBackgroundView.isHidden = true
                cell.mainBackgroundView.backgroundColor = .white
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? InterestsCell else { return }
//        if !selectedInterestsArray.contains(cell.interestsLabel.text!) {
//            let index = selectedInterestsArray.count
//            cell.numberLabel.text = "\(index - 1)"
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InterestsCell else { return }
        if let index = selectedInterestsArray.firstIndex(of: cell.interestsLabel.text!) {
            selectedInterestsArray.remove(at: index)
        } else {
            if selectedInterestsArray.count >= 7 { return }
            selectedInterestsArray.append(cell.interestsLabel.text!)
        }
        
        selectedInterestCountLabel.text = "\(selectedInterestsArray.count)"
        saveButton.isEnabled = !selectedInterestsArray.isEmpty
        
        self.collectionView.reloadData()
    }
    
}
