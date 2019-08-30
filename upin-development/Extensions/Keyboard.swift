//
//  Keyboard.swift
//  Upin
//
//  Created by Leonardo Barroeta on 8/25/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    
}

