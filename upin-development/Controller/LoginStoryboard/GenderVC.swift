//
//  GenderVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class GenderVC: UIViewController {

    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var otherGenderTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    private var birthdatePicker: UIDatePicker?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        setDatePicker()
        segmentedControlChanged(genderSegmentedControl!)
        birthdateTextField.inputView = birthdatePicker
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        updateGenderAndBirthdate()
        self.performSegue(withIdentifier: "ProfilePictureVC", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateGenderAndBirthdate() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Get age
        let stringBirthdate: String = birthdateTextField.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let date = dateFormatter.date(from: stringBirthdate)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date!)
        let now = Date()
        let finalYear = calendar.date(from: components)
        let age = calendar.dateComponents([.year], from: finalYear!, to: now)
        
        var userAge = age.year!
                
        var userData = [String: Any]()
        
        if self.genderSegmentedControl.selectedSegmentIndex == 0 {
            userData = [
                "gender": "Male",
                "birthdate": birthdateTextField.text!,
                "age": userAge
            ]
        } else if self.genderSegmentedControl.selectedSegmentIndex == 1 {
            userData = [
                "gender": "Female",
                "birthdate": birthdateTextField.text!,
                "age": userAge
            ]
        } else {
            userData = [
                "gender": "Other",
                "otherGenderDescription": otherGenderTextField.text!,
                "birthdate": birthdateTextField.text!,
                "age": userAge
            ]
        }
        
        Firestore.firestore().collection("users").document(user.uid).updateData(userData) { (error) in
            if let error = error {
                self.authErrorHandle(error: error)
                print(error.localizedDescription)
                return
            }
        }
        
    }
        
    func setDatePicker() {
        birthdatePicker = UIDatePicker()
        birthdatePicker?.datePickerMode = .date
        birthdatePicker?.addTarget(self, action: #selector(dateChanged(birthdatePicker:)), for: .valueChanged)
        birthdatePicker?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    @objc func dateChanged(birthdatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        birthdateTextField.text = dateFormatter.string(from: birthdatePicker.date)
    }

    @IBAction func segmentedControlChanged(_ sender: Any) {
        switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            otherGenderTextField.isHidden = true
        case 1:
            otherGenderTextField.isHidden = true
        case 2:
            otherGenderTextField.isHidden = false
        default:
            otherGenderTextField.isHidden = true
        }
    }
    

}
