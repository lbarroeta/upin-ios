//
//  UserService.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/7/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation
import Firebase

let UserService = _UserService()

final class _UserService {
    var user = User()
    var selectedInterests = [Interests]()
    let auth = Auth.auth()
    let database = Firestore.firestore()
    var userListener: ListenerRegistration? = nil
    var interestsListener: ListenerRegistration? = nil
    
    
    func getCurrentUserInfo() {
        guard let currentUser = auth.currentUser else { return }
        
        let userRef = database.collection("users").document(currentUser.uid)
        userListener = userRef.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            self.user = User.init(data: data)
            
        })
        
        let interestsRef = userRef.collection("interests")
        interestsListener = interestsRef.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snapshot?.documents.forEach({ (document) in
                let interest = Interests.init(data: document.data())
                self.selectedInterests.append(interest)
            })
        })
    }
    
    func signOutUser() {
        userListener?.remove()
        userListener = nil
        interestsListener?.remove()
        interestsListener = nil
        
        user = User()
        selectedInterests.removeAll()
    }
    

}
