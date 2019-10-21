//
//  InterestsCell.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/6/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class InterestsCell: UICollectionViewCell {
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var numberBackgroundView: UIView!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    var selectedCell = false
    
    override var isSelected: Bool {
        didSet {
            if selectedCell == false {
                numberBackgroundView.isHidden = false
                selectedCell = true
            } else {
                numberBackgroundView.isHidden = true
                selectedCell = false
            }
        }
    }
    
    
    override func awakeFromNib() {
        mainBackgroundView.layer.borderWidth = 1
        mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.8666666667, blue: 0.6941176471, alpha: 1)
        mainBackgroundView.layer.cornerRadius = 15
        
        numberBackgroundView.layer.borderWidth = 0.5
        numberBackgroundView.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.8666666667, blue: 0.6941176471, alpha: 1)
        numberBackgroundView.layer.cornerRadius = 10
        
        numberBackgroundView.isHidden = true
        
    }
    
    func configureCell(interests: Interests) {
        interestsLabel.text = interests.name
    }
}

class ProfileInterestsCell: UICollectionViewCell {
    
    
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
