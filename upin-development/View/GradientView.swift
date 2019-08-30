//
//  GradientView.swift
//  Upin
//
//  Created by Leonardo Barroeta on 8/25/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.3737931848, green: 0.8683760166, blue: 0.6924387813, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.9371697307, green: 0.4508494139, blue: 0.3965468109, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        //        gradientLayer.startPoint = CGPoint(x: 1, y: 1)
        //        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0.5, 1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
