//
//  EditProfileInterestCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/26/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class EditProfileInterestCell: UICollectionViewCell {
    @IBOutlet weak var interestNameLabel: UILabel!
    @IBOutlet weak var mainBackgroundView: UIView!
    
    func configureCell(interests: Interests) {
        self.interestNameLabel.text = interests.name
    }
}
