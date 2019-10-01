//
//  UserConnection.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/30/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation

struct UserConnection {
    var user_id: String
    var firstName: String
    var lastName: String
    var interests: [String]
    var profileImage: String
    
    init(data: [String: Any]) {
        self.user_id = data["user_id"] as? String ?? ""
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.interests = data["interests"] as? Array ?? [""]
        self.profileImage = data["profile_image"] as? String ?? ""
    }
}
