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
import CoreLocation

class NotificationsPinDetailVC: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentUserlatitude: Double?
    var currentUserlongitude: Double?
    var listener: ListenerRegistration!
    
    var selectedPin: Pins!
    var pin_id: String?
    var pin_latitude: String?
    var pin_longitude: String?
    var pin_starting_time: String?
    var pin_ending_time: String?
    var host_id: String?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var pin_photo: UIImageView!
    @IBOutlet weak var pin_title: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var extraAddressLabel: UILabel!
    @IBOutlet weak var hostPhoto: UIImageView!
    @IBOutlet weak var milesLabel: UILabel!
    
    @IBOutlet weak var minAgeLabel: UIButton!
    @IBOutlet weak var maxAgeLabel: UIButton!
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
        
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        
        pinListener()
        highestAgeListener()
        lowestAgeListener()
        
        // User counters
        usersAtPinListener()
        usersJoinedListener()
        usersInvitedListener()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentUserlatitude = location.latitude
        currentUserlongitude = location.longitude
    }
    
    func pinListener() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let pinReference = Firestore.firestore().collection("pins").document(selectedPin.id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pinReference.addSnapshotListener { (snapshot, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                
                let pin_id = data["pin_id"] as? String
                let pin_end_time = data["ending_time"] as? String
                let pin_start_time = data["starting_time"] as? String
                let map_search_description = data["map_search_description"] as? String
                let pin_title = data["pin_title"] as? String
                let pin_description = data["short_description"] as? String
                let pin_image = data["pin_photo"] as? String
                let data_pin_latitude = String(data["latitude"] as! Double)
                let data_pin_longitude = String(data["longitude"] as! Double)
                let extra_directions = data["extra_directions"] as? String
                let host_id = data["host_id"] as? String
                let has_ended = data["has_ended"] as? Bool
                
                
                self.pin_id = pin_id
                self.endingTimeLabel.text = pin_end_time
                self.startTimeLabel.text = pin_start_time
                self.pin_ending_time = pin_end_time
                self.pin_starting_time = pin_start_time
                self.addressButton.setTitle(map_search_description!, for: .normal)
                self.pin_title.text = pin_title
                self.descriptionLabel.text = pin_description
                self.navigationItemTitle.title = "\(pin_title!) Details"
                guard let pinImageURL = URL(string: pin_image!) else { return }
                self.pin_photo.kf.setImage(with: pinImageURL)
                self.pin_latitude = data_pin_latitude
                self.pin_longitude = data_pin_longitude
                // Requested to not be displayed: self.extraAddressLabel.text = extra_directions
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
                
                //Pin Location
                let pinLocation = CLLocation(latitude: Double(data_pin_latitude) as! CLLocationDegrees, longitude: Double(data_pin_longitude) as! CLLocationDegrees)
                let userLocation = CLLocation(latitude: self.currentUserlatitude!, longitude: self.currentUserlongitude!)
                let distance = pinLocation.distance(from: userLocation)
                let convertToMiles = distance * 0.000621371
                let milesToString = String(format: "%.2f", convertToMiles)
                self.milesLabel.text = "\(milesToString)"
                
                //Pin dates
                let stringStartDate: String = pin_start_time!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
                let date = dateFormatter.date(from: stringStartDate)
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
                let nowDate = Date()
                let pinDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
                let currentDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nowDate)

                let endFirebaseDate: String = pin_end_time!
                let endDateFormatter = DateFormatter()
                endDateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
                let endDate = dateFormatter.date(from: endFirebaseDate)
                let endCalendar = Calendar.current
                let endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endDate!)
                let endNowDate = Date()
                let endPinDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endDate!)
                let endCurrentDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endNowDate)
                
                
                if (pinDate.day! - currentDate.day!) == 0 {
                    if pinDate.minute! < 10 {
                        self.startingDateLabel.text = "Today at"
                        self.endingDateLabel.text = "Today at"
                        
                        self.startTimeLabel.text = "\(pinDate.hour!):0\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.hour!):0\(endPinDate.minute!)"
                    } else {
                        self.startingDateLabel.text = "Today at"
                        self.endingDateLabel.text = "Today at"
                        
                        self.startTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.hour!):\(endPinDate.minute!)"
                    }
                } else if (pinDate.day! - currentDate.day!) == 1 {
                    self.startingDateLabel.text = "Starting tomorrow at"
                    self.endingDateLabel.text = "Starting tomorrow at"

                    if pinDate.minute! < 10 {
                        self.startTimeLabel.text = "\(pinDate.hour!):0\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.hour!):0\(endPinDate.minute!)"
                    } else {
                        self.startTimeLabel.text = "\(pinDate.hour!):\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.hour!):\(endPinDate.minute!)"
                    }
                } else if (pinDate.day! - currentDate.day!) >= 2 {
                    
                    self.startingDateLabel.text = "Starting at"
                    self.endingDateLabel.text = "Starting at"
                    
                    if pinDate.minute! < 10 {
                        self.startTimeLabel.text = "\(pinDate.month!)/\(pinDate.day!)/\(pinDate.year!)  \(pinDate.hour!):0\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.month!)/\(endPinDate.day!)/\(endPinDate.year!)  \(endPinDate.hour!):0\(endPinDate.minute!)"
                    } else {
                        self.startTimeLabel.text = "\(pinDate.month!)/\(pinDate.day!)/\(pinDate.year!)  \(pinDate.hour!):\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.month!)/\(endPinDate.day!)/\(endPinDate.year!)  \(endPinDate.hour!):\(endPinDate.minute!)"
                    }
                } else {
                    
                    self.startingDateLabel.text = "Starting at"
                    self.endingDateLabel.text = "Starting at"
                
                    if pinDate.minute! < 10 {
                        self.startTimeLabel.text = "\(pinDate.month!)/\(pinDate.day!)/\(pinDate.year!)  \(pinDate.hour!):0\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.month!)/\(endPinDate.day!)/\(endPinDate.year!)  \(endPinDate.hour!):0\(endPinDate.minute!)"
                    } else {
                        self.startTimeLabel.text = "\(pinDate.month!)/\(pinDate.day!)/\(pinDate.year!)  \(pinDate.hour!):\(pinDate.minute!)"
                        self.endingTimeLabel.text = "\(endPinDate.month!)/\(endPinDate.day!)/\(endPinDate.year!)  \(endPinDate.hour!):\(endPinDate.minute!)"
                    }
                }
                
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
                
            }
        }
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
            
                self.maxAgeLabel.setTitle("\(age!)", for: .normal)
                
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
                self.minAgeLabel.setTitle("\(age!)", for: .normal)
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
    
    func usersInvitedListener() {
        let pinRefererence = Firestore.firestore().collection("pins").document(selectedPin.id).collection("users").whereField("accepted_invitation", isEqualTo: false)
        pinRefererence.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            let counter = snapshot?.count
            self.invitedButton.setTitle(String(counter!), for: .normal)
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
        } else if segue.identifier == "UserInvitedVC" {
            let vc = segue.destination as! UserInvitedVC
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
        self.performSegue(withIdentifier: "UserJoinedVC", sender: self)
    }
    
    @IBAction func invitedButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "UserInvitedVC", sender: self)
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

