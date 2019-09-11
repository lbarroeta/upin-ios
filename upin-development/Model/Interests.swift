//
//  Interests.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/6/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation

struct Interests {
    var id: String
    var name: String
    var is_active: Bool
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.is_active = data["is_active"] as? Bool ?? true
    }
    
}
