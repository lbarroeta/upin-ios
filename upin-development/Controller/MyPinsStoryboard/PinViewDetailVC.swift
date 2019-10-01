//
//  PinViewDetailVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/15/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Kingfisher

class PinViewDetailVC: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var pinTitleLabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var startingTimeLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var endingTimeLabel: UILabel!
    @IBOutlet weak var pinDescriptionLabel: UILabel!
    
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    
    @IBOutlet weak var addressButton: UIButton!
    
    // Segue variables
    var pin_latitude: String?
    var pin_longitude: String?
    var pin_title: String?
    var pin_image: String?
    var pin_description: String?
    var pin_host_id: String?
    var pin_starting_time: String?
    var pin_ending_time: String?
    var map_search_description: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinTitleLabel.text = pin_title
        startingTimeLabel.text = pin_starting_time
        endingTimeLabel.text = pin_ending_time
        addressButton.setTitle(map_search_description, for: .normal)
        
        
        setTimeLabels()
        // Setting image
        guard let pinImageURL = URL(string: pin_image!) else { return }
        pinImage.kf.setImage(with: pinImageURL)
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func addressButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(pin_latitude!),\(pin_longitude!)")! as URL, options: [:], completionHandler: nil)
    }
    
    func setTimeLabels() {
        let stringStartDate: String = pin_starting_time!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let date = dateFormatter.date(from: stringStartDate)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
        let nowDate = Date()
        let pinDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
        let currentDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nowDate)
        
        print(pinDate.hour!)
        
        if pinDate.day == currentDate.day {
            self.startingTimeLabel.text = "Starting today at:"
        } else if (pinDate.day != currentDate.day) {
            self.startingTimeLabel.text = "Starting at:"
        }
    }
}
