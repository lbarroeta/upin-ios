//
//  UserAtPinVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/30/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class UserAtPinVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var users = [UserAtPin]()
    var selectedPin = ""
    var selectedUser: UserAtPin!
    var listener: ListenerRegistration!
    var database: Firestore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear

        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
        users.removeAll()
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func userListener() {
        listener = Firestore.firestore().collection("pins").document(selectedPin).collection("users").whereField("is_host", isEqualTo: true).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            
            snapshot?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let user = UserAtPin.init(data: data)
                
                switch change.type {
                case .added:
                    self.onUserAdded(change: change, user: user)
                case .modified:
                    self.onUserModified(change: change, user: user)
                case .removed:
                    self.onUserRemoved(change: change)
                }
            })
        })
    }
    
    @IBAction func pinDetailsButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension UserAtPinVC: UITableViewDelegate, UITableViewDataSource {
    
    func onUserAdded(change: DocumentChange, user: UserAtPin) {
        let newIndex = Int(change.newIndex)
        users.insert(user, at: newIndex)
        tableView.insertRows(at: [IndexPath.init(item: newIndex, section: 0)], with: .automatic)
    }
    
    func onUserModified(change: DocumentChange, user: UserAtPin) {
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            users[index] = user
            tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            users.remove(at: oldIndex)
            users.insert(user, at: newIndex)
            tableView.moveRow(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onUserRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        users.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath.init(item: oldIndex, section: 0)], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserAtPinCell", for: indexPath) as? UserAtPinCell {
            
            cell.firstInterestLabel.textColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.firstInterestLabel.layer.borderColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.firstInterestLabel.layer.borderWidth = 1.0
            cell.firstInterestLabel.layer.cornerRadius = 12.5
            cell.firstInterestLabel.clipsToBounds = true
            
            
            cell.secondInterestLabel.textColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.secondInterestLabel.layer.borderColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.secondInterestLabel.layer.borderWidth = 1.0
            cell.secondInterestLabel.layer.cornerRadius = 12.5
            cell.secondInterestLabel.clipsToBounds = true
            
            cell.thirdInterestLabel.textColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.thirdInterestLabel.layer.borderColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.thirdInterestLabel.layer.borderWidth = 1.0
            cell.thirdInterestLabel.layer.cornerRadius = 12.5
            cell.thirdInterestLabel.clipsToBounds = true
            
            cell.configureCell(users: users[indexPath.item])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.item]
        performSegue(withIdentifier: "AtPinUserProfileVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AtPinUserProfileVC" {
            if let destination = segue.destination as? AtPinUserProfileVC {
                destination.selectedUser = selectedUser
            }
        }
    }
    
}
