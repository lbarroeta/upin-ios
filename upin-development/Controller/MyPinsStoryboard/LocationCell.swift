//
//  LocationCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 10/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import CoreLocation

class AddressCell: UITableViewCell {
    
    convenience init() {
        self.init(style: .subtitle, reuseIdentifier: nil)
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setupData(lat: Double, long: Double) {
        geocode(latitude: lat, longitude: long)
        
    }
    
    func geocode(latitude: Double, longitude: Double)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                return
            }
            var components = [String]()
            if let data = placemark.administrativeArea {
                components.append(data)
            }
            if let data = placemark.subLocality {
                components.append(data)
            }
            if let data = placemark.subAdministrativeArea {
                components.append(data)
            }
            if let data = placemark.locality {
                components.append(data)
            }
            if let data = placemark.country {
                components.append(data)
            }
        
            self.detailTextLabel?.text = components.joined(separator: ", ")
        }
    }
}

