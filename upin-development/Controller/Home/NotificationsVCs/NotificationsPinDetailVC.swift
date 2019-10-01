//
//  NotificationsPinDetailVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/15/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import Geofirestore

class NotificationsPinDetailVC: UIViewController {
    
    var selectedPin: Pins!
    var pin_id: String?
    var pin_latitude: String?
    var pin_longitude: String?
    var pin_starting_time: String?
    var pin_ending_time: String?
    var host_id: String?
    
    @IBOutlet weak var pin_photo: UIImageView!
    @IBOutlet weak var pin_title: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var extraAddressLabel: UILabel!
    @IBOutlet weak var hostPhoto: UIImageView!
    
    @IBOutlet weak var minAgeLabel: UILabel!
    @IBOutlet weak var maxAgeLabel: UILabel!
    @IBOutlet weak var atPinButton: UIButton!
    @IBOutlet weak var joinedButton: UIButton!
    @IBOutlet weak var invitedButton: UIButton!
    
    @IBOutlet weak var startingDateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endingDateLabel: UILabel!
    @IBOutlet weak var endingTimeLabel: UILabel!
    
    @IBOutlet weak var endButton: ActionButton!
    @IBOutlet weak var joinButton: ActionButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinListener()
        highestAgeListener()
        lowestAgeListener()
        usersAtPinListener()
        usersJoinedListener()
    }
    
    func pinListener() {
        guard let currentUser = Auth.auth().currentUser else { return }
        // Getting data from selected pin
        Firestore.firestore().collection("pins").document(selectedPin.id).getDocument(completion: { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let data = snapshot?.data() else { return }

            let pin_id = data["pin_id"] as? String
            let data_pin_latitude = String(data["latitude"] as! Double)
            let data_pin_longitude = String(data["longitude"] as! Double)
            let pin_title = data["pin_title"] as? String
            let pin_description = data["short_description"] as? String
            let pin_end_time = data["ending_time"] as? String
            let pin_start_time = data["starting_time"] as? String
            let pin_image = data["pin_photo"] as? String
            let map_search_description = data["map_search_description"] as? String
            let extra_directions = data["extra_directions"] as? String
            let host_id = data["host_id"] as? String
            let has_ended = data["has_ended"] as? Bool

            self.pin_id = pin_id
            self.endingTimeLabel.text = pin_end_time
            self.startTimeLabel.text = pin_start_time
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
            
            self.host_id = host_id
            
            if (self.host_id == currentUser.uid) && (has_ended == false) {
                self.endButton.isHidden = false
                self.endButton.isEnabled = true
                self.joinButton.isHidden = true
            } else if (self.host_id == currentUser.uid) && (has_ended == true) {
                self.endButton.isHidden = false
                self.endButton.setTitle("This pin has ended", for: .normal)
                self.endButton.isEnabled = false
                self.joinButton.isHidden = true
            } else if (self.host_id != currentUser.uid) && (has_ended == false) {
                self.joinButton.isHidden = false
                self.endButton.isHidden = true
            } else if (self.host_id != currentUser.uid) && (has_ended == true) {
                self.joinButton.isHidden = true
                self.endButton.isHidden = true
            }
            
            // Setting host_image.
            Firestore.firestore().collection("users").document(host_id!).getDocument { (snapshot, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                let profileImagePath = data["profilePictures"] as? [String: Any]
                guard let mainProfileImagePath = profileImagePath?["mainProfileImage"] as? String else { return }
                guard let mainProfileImageURL = URL(string: mainProfileImagePath) else { return }
                self.hostPhoto.kf.setImage(with: mainProfileImageURL)
            }
            
            // Pin dates
            let stringStartDate: String = pin_start_time!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            let date = dateFormatter.date(from: stringStartDate)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day, .hour, .minute], from: date!)
            let nowDate = Date()
            let pinDate = calendar.dateComponents([.day, .hour, .minute], from: date!)
            let currentDate = calendar.dateComponents([.day, .hour, .minute], from: nowDate)
            
            if pinDate.day == currentDate.day {
                if currentDate.hour! >= 12 {
                    self.startingDateLabel.text = "Starting today at"
                    self.startTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)pm"
                    
                    self.endingDateLabel.text = "Ending today at"
                    self.endingTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)pm"
                } else {
                    self.startingDateLabel.text = "Starting today at"
                    self.startTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)am"
                    
                    self.endingDateLabel.text = "Ending today at"
                    self.endingTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)am"
                }
                
            } else if (pinDate.day != currentDate.day) {
                self.startingDateLabel.text = "Starting tomorrow at"
                self.startTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)"
                
                self.endingDateLabel.text = "Ending tomorrow at"
                self.endingTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)"
            }
            
        })
    }
    
    func highestAgeListener() {
        let ageReference = Firestore.firestore().collection("pins").document(selectedPin.id).collection("users").whereField("age", isLessThan: 100).order(by: "age", descending: true).limit(to: 1)
        ageReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                let data = document.data()
                let age = data["age"]
            
                self.maxAgeLabel.text = "\(age!)"
                
            }
        }
    }
    
    func lowestAgeListener() {
        let ageReference = Firestore.firestore().collection("pins").document(selectedPin.id).collection("users").whereField("age", isLessThan: 100).order(by: "age", descending: false).limit(to: 1)
        
        ageReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                let data = document.data()
                let age = data["age"]
                self.minAgeLabel.text = "\(age!)"
            }
        }
    }
    
    func usersAtPinListener() {
        let pinReference = Firestore.firestore().collection("pins").document(selectedPin.id).collection("users").whereField("is_host", isEqualTo: true).limit(to: 1)
        
        pinReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            let counter = snapshot?.count
            self.atPinButton.setTitle(String(counter!), for: .normal)
        }
    }
    
    func usersJoinedListener() {
        let pinReference = Firestore.firestore().collection("pins").document(selectedPin.id).collection("users").whereField("is_host", isEqualTo: false)
        
        pinReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            
            let counter = snapshot?.count
            self.joinedButton.setTitle(String(counter!), for: .normal)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserAtPinVC" {
            let vc = segue.destination as! UserAtPinVC
            vc.selectedPin = pin_id!
        } else if segue.identifier == "EditPinVC" {
            let vc = segue.destination as! EditPinVC
            vc.selectedPin = pin_id!
        } else if segue.identifier == "UserJoinedVC" {
            let vc = segue.destination as! UserJoinedVC
            vc.selectedPin = pin_id!
        }
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "EditPinVC", sender: self)
    }
    
    
    @IBAction func atPinButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "UserAtPinVC", sender: self)
    }
    
    @IBAction func joinedButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func invitedButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func endButtonPressed(_ sender: Any) {
        var pinData = [String: Any]()
        pinData = [
            "has_ended": true
        ]
        
        self.endPinAler(title: "End pin", msg: "Are you sure you want to end this Pin?", handlerOk: { (action) in
            let pinReference = Firestore.firestore().collection("pins").document(self.selectedPin.id)
            pinReference.updateData(pinData) { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
            
        }, handlerCancel: nil)
    }
    
    
    @IBAction func addressButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(pin_latitude!),\(pin_longitude!)")! as URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let share = UIAlertAction(title: "Share", style: .default) { (action) in
            let activityController = UIActivityViewController(activityItems: [""], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
        let connections = UIAlertAction(title: "Connections", style: .default) { (action) in
            self.performSegue(withIdentifier: "InviteConnectionsVC", sender: self)
        }
        
        actionSheet.addAction(share)
        actionSheet.addAction(connections)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

