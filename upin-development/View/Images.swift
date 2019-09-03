//
//  Images.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/3/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {
    
    var originalSize: CGRect?
    
    func setUpView() {
        originalSize = self.frame
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    override func awakeFromNib() {
        setUpView()
    }
    
    
}
