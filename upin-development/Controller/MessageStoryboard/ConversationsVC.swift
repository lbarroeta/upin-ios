//
//  ConversationsVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/19/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class ConversationsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        messageLabel.text = "You have no messages"

    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
