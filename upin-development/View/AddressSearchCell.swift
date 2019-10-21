//
//  AddressSearchCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 10/16/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class AddressSearchCell: UITableViewCell {

    @IBOutlet weak var pinMarker: UIImageView!
    
    override class func awakeFromNib() {
        
    }
    
    func configureCell() {
        pinMarker.image = #imageLiteral(resourceName: "GPS Marker")
    }
    
    static var identifier: String = "AddressSearchCell"
    
}
