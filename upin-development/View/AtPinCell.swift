//
//  AtPinCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/29/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class AtPinCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func configureCell(users: User) {
        userNameLabel.text = users.firstName
    }

}
