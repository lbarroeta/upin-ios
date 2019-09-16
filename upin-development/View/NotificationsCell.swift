//
//  NotificationsCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/15/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationsCell: UITableViewCell {
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinTitle: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(myPins: Pins) {
        pinTitle.text = myPins.pin_title
        if let url = URL(string: myPins.pin_photo) {
            pinImage.kf.setImage(with: url)
        }
    }

}
