//
//  Pins.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation

struct Pins {
    var id: String
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
    }
}
