//
//  FirebaseErrorHandler.swift
//  Upin
//
//  Created by Leonardo Barroeta on 8/25/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    func authErrorHandle(error: Error) {
        
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            let alert = UIAlertController.init(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use. Pick another email."
        case .invalidEmail:
            return "The email is invalid. Please verify the email."
        case .invalidRecipientEmail:
            return "The email is invalid. Please verify the email."
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password or email is incorrect."
        case .missingPhoneNumber:
            return "Must add a phone number"
        case .invalidPhoneNumber:
            return "Invalid phone number, please verify."
        case .userDisabled:
            return "User has been disabled, please try again later."
        case .webSignInUserInteractionFailure:
            return "Unable to sign in please try again."
        default:
            return "Sorry, something went wrong, please try again."
        }
    }
}
