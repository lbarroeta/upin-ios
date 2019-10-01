//
//  UserInvited.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 10/1/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation

struct UserInvited {
    var user_id: String
    var firstName: String
    var lastName: String
    var interests: [String]
    var gender: String
    var profileImage: String
    var age: Int
    
    init(data: [String: Any]) {
        self.user_id = data["user_id"] as? String ?? ""
        self.firstName = data["first_name"] as? String ?? ""
        self.lastName = data["last_name"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.interests = data["interests"] as? Array ?? [""]
        self.profileImage = data["profile_image"] as? String ?? ""
        self.age = data["age"] as? Int ?? 0
    }
}
