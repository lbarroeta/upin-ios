//
//  User.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/2/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation

struct User:Codable {
    var id: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var birthdate: String = ""
    var gender: String = ""
    var otherGender: String = ""
    var profilePictures: String = ""
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.birthdate = data["birthdate"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.profilePictures = data["profilePictures"] as? String ?? ""
    }
}
