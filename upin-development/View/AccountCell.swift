//
//  AccountCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/19/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class MyAccountPhoneCell: UITableViewCell {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
