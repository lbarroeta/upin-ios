//
//  JoinedVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/16/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class JoinedVC: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageLabel.text = "You are not currently joined to any pins."
    }

}
