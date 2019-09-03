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
}
