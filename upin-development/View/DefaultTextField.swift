//
//  DefaultTextField.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 10/16/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class DefaultTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       styleSetup()
    }
       
    required override init(frame: CGRect) {
       super.init(frame: frame)
       styleSetup()
    }
    
    func styleSetup(){
        self.clearButtonMode = .whileEditing
    }
    

}
