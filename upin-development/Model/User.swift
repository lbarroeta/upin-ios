//
//  User.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/2/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation

struct User {
    var id: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var birthdate: String = ""
    var gender: String = ""
    var otherGender: String = ""
    var phone_number: String = ""
    
    init(id: String = "",
         firstName: String = "",
         lastName: String = "",
         email: String = "",
         birthdate: String = "",
         gender: String = "",
         otherGender: String = "") {
        
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.birthdate = birthdate
        self.gender = gender
        self.otherGender = otherGender
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.birthdate = data["birthdate"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.phone_number = data["phone_number"] as? String ?? ""
    }
    
    static func modelToData(user: User) -> [String: Any] {
        let data: [String: Any] = [
            "id": user.id,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "email": user.email,
            "birthdate": user.birthdate,
            "gender": user.gender,
            "otherGender": user.otherGender,
            "phone_number": user.phone_number
        ]
        
        return data
    }
}
