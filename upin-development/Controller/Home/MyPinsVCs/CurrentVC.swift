//
//  CurrentVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/16/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class CurrentVC: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageLabel.text = "You are currently not hosting or joined to any pins."
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
