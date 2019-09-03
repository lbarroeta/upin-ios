//
//  Alerts.swift
//  Upin
//
//  Created by Leonardo Barroeta on 8/25/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func simpleAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func signOutAlert(title: String, msg: String, handlerOK: ((UIAlertAction) -> Void)?, handlerCancel: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: title, style: .destructive, handler: handlerOK)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: handlerCancel)
        alert.addAction(action)
        alert.addAction(actionCancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func signUpAlert(title: String, msg: String, handlerOK: ((UIAlertAction) -> Void)?, handlerCancel: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes!", style: .default, handler: handlerOK)
        let actionCancel = UIAlertAction(title: "No", style: .cancel, handler: handlerCancel)
        alert.addAction(action)
        alert.addAction(actionCancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func resendCodeAlert(title: String, msg: String, handlerOk: ((UIAlertAction) -> Void)?, handlerCancel: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: title, style: .cancel, handler: handlerOk)
        let actionCancel = UIAlertAction(title: title, style: .cancel, handler: handlerCancel)
        alert.addAction(actionCancel)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
}

