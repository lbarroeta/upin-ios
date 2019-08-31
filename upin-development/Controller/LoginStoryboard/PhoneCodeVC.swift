//
//  PhoneCodeVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/31/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class PhoneCodeVC: UIViewController {
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    
    var finalUserId = ""
    var userPhoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberLabel.text = userPhoneNumber
        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        
    }
}
