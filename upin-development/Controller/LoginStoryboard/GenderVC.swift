//
//  GenderVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class GenderVC: UIViewController {

    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var otherGenderTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
