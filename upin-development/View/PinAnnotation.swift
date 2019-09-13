//
//  PinAnnotation.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/12/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
}
