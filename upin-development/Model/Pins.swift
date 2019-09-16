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
    var ending_time: String
    var extra_directions: String
    var host_id: String
    var latitude: Double
    var longitude: Double
    var map_search_description: String
    var pin_photo: String
    var pin_title: String
    var short_description: String
    var starting_time: String
    
    
    init(data: [String: Any]) {
        self.id = data["pin_id"] as? String ?? ""
        self.ending_time = data["ending_time"] as? String ?? ""
        self.extra_directions = data[ "extra_directions"] as? String ?? ""
        self.host_id = data["host_id"] as? String ?? ""
        self.latitude = (data["latitude"] as? Double)!
        self.longitude = (data["longitude"] as? Double)!
        self.map_search_description = data["map_search_description"] as? String ?? ""
        self.pin_photo = data["pin_photo"] as? String ?? ""
        self.pin_title = data["pin_title"] as? String ?? ""
        self.short_description = data["short_description"] as? String ?? ""
        self.starting_time = data["starting_time"] as? String ?? ""
    }
}
