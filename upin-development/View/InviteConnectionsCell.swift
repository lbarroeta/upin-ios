//
//  InviteConnectionsCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/30/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class InviteConnectionsCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstInterestLabel: UILabel!
    @IBOutlet weak var secondInterestLabel: UILabel!
    @IBOutlet weak var thirdInterestLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(users: UserConnection) {
        firstNameLabel.text = users.firstName
        lastNameLabel.text = users.lastName
        firstInterestLabel.text = String(users.interests[0])
        secondInterestLabel.text = String(users.interests[1])
        thirdInterestLabel.text = String(users.interests[2])
        
        if let url = URL(string: users.profileImage) {
            profileImage.kf.setImage(with: url)
        }
    }

}

class UserInvitedProfileCell: UICollectionViewCell {
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var counterBackgroundView: UIView!
    @IBOutlet weak var interestsCountLabel: UILabel!

    func configureCell(interests: Interests) {
        interestsLabel.text = interests.name
    }

    override func awakeFromNib() {
        mainBackgroundView.layer.borderWidth = 1
        mainBackgroundView.layer.cornerRadius = 20
        
        counterBackgroundView.layer.borderWidth = 0.5
        counterBackgroundView.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.8666666667, blue: 0.6941176471, alpha: 1)
        counterBackgroundView.layer.cornerRadius = 10
        
        counterBackgroundView.isHidden = true
    }
}
