//
//  MyPinsVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class MyPinsVC: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createPinButtonPressed(_ sender: Any) {
        presentMyPinsStoryboard()
    }
    
    fileprivate func presentMyPinsStoryboard() {
        let storyboard = UIStoryboard(name: Storyboards.MyPinsStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: MyPinsViewControllers.StepOneVC)
        present(controller, animated: true, completion: nil)
    }


    
    
}
