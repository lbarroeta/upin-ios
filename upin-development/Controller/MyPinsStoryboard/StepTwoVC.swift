//
//  StepTwoVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class StepTwoVC: UIViewController {

    @IBOutlet weak var pinImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ToStepThreeVC", sender: self)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
