//
//  MessagesVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/19/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class MessagesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func conversationsButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
