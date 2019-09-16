//
//  PinHomeDetailVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/15/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class PinHomeDetailVC: UIViewController {
    
    var pin_latitude: String?
    var pin_longitude: String?
    var pin_title: String?
    var pin_image: String?
    var pin_description: String?
    var pin_host_id: String?
    var pin_starting_time: String?
    var pin_ending_time: String?
    var map_search_description: String?
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinTitleLabel: UILabel!
    @IBOutlet weak var startingTimeLabel: UILabel!
    @IBOutlet weak var startingTimeDateLabel: UILabel!
    @IBOutlet weak var endingTimeLabel: UILabel!
    @IBOutlet weak var endingTimeDateLabel: UILabel!
    @IBOutlet weak var pinDescriptionLabel: UILabel!
    @IBOutlet weak var hostImage: UIImageView!
    @IBOutlet weak var viewPinButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pinTitleLabel.text = pin_title
        pinDescriptionLabel.text = pin_description
        startingTimeDateLabel.text = pin_starting_time
        endingTimeDateLabel.text = pin_ending_time
        
        setTimeLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PinViewDetailVC
        controller.pin_image = pin_image
        controller.pin_title = pin_title
        controller.pin_starting_time = pin_starting_time
        controller.pin_ending_time = pin_ending_time
        controller.pin_description = pin_description
        controller.map_search_description = map_search_description
        controller.pin_longitude = pin_longitude
        controller.pin_latitude = pin_latitude
    }
    
    @IBAction func viewPinButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "PinViewDetailVC", sender: self)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
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
        
        print(currentDate.month)
        
        if (pinDate.day == currentDate.day) || (pinDate.month! == currentDate.month!) {
            self.startingTimeLabel.text = "Starting today at:"
        } else if (pinDate.day != currentDate.day) || (pinDate.month! != currentDate.month!) {
            self.startingTimeLabel.text = "Starting at:"
        }
    }
    
}
