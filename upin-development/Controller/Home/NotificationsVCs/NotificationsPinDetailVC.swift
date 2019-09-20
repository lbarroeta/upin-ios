//
//  NotificationsPinDetailVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/15/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class NotificationsPinDetailVC: UIViewController {
    
    var selectedPin: Pins!
    var pin_latitude: String?
    var pin_longitude: String?
    var pin_starting_time: String?
    var pin_ending_time: String?
    
    @IBOutlet weak var pin_photo: UIImageView!
    @IBOutlet weak var pin_title: UILabel!
    @IBOutlet weak var startingDateLabel: UILabel!
    @IBOutlet weak var endingDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var extraAddressLabel: UILabel!
    @IBOutlet weak var hostPhoto: UIImageView!
    @IBOutlet weak var startingTimeLabel: UILabel!
    @IBOutlet weak var endingTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinListener()
    }
    
    func pinListener() {
        
        Firestore.firestore().collection("pins").document(selectedPin.id).getDocument(completion: { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let data = snapshot?.data() else { return }

            let data_pin_latitude = String(data["latitude"] as! Double)
            let data_pin_longitude = String(data["longitude"] as! Double)
            let pin_title = data["pin_title"] as? String
            let pin_description = data["short_description"] as? String
            let pin_end_time = data["ending_time"] as? String
            let pin_start_time = data["starting_time"] as? String
            let pin_image = data["pin_photo"] as? String
            let map_search_description = data["map_search_description"] as? String
            let extra_directions = data["extra_directions"] as? String

            self.endingTimeLabel.text = pin_end_time
            self.startingTimeLabel.text = pin_start_time
            self.addressButton.setTitle(map_search_description!, for: .normal)

            self.pin_ending_time = pin_end_time
            self.pin_starting_time = pin_start_time

            self.pin_title.text = pin_title
            self.descriptionLabel.text = pin_description
            self.extraAddressLabel.text = extra_directions

            guard let pinImageURL = URL(string: pin_image!) else { return }
            self.pin_photo.kf.setImage(with: pinImageURL)

            self.pin_latitude = data_pin_latitude
            self.pin_longitude = data_pin_longitude

        })
    }
    
    @IBAction func addressButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(pin_latitude!),\(pin_longitude!)")! as URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
            self.startingDateLabel.text = "Starting today at:"
        } else if (pinDate.day != currentDate.day) {
            self.startingDateLabel.text = "Starting at:"
        }
    }
    

}
