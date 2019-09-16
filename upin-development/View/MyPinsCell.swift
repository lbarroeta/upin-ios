//
//  MyPinsCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class MyPinsCell: UITableViewCell {
    
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinTitleLabel: UILabel!
    @IBOutlet weak var pinDateLabel: UILabel!
    @IBOutlet weak var pinTimeLabel: UILabel!
    @IBOutlet weak var pinMilesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(myPins: Pins) {
        pinTitleLabel.text = myPins.pin_title
        if let url = URL(string: myPins.pin_photo) {
            pinImage.kf.setImage(with: url)
        }
    }

}
