//
//  StepFourVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class StepFourVC: UIViewController {

    @IBOutlet weak var startingTimeTextField: UITextField!
    @IBOutlet weak var endingTimeTextField: UITextField!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endingTimeLabel: UILabel!
    
    private var startingDatePicker: UIDatePicker?
    private var endingDatePicker: UIDatePicker?
    
    // Segue variables
    var pin_title = ""
    var short_description = ""
    var pin_image: UIImage!
    var latitude: Double = 0
    var longitude: Double = 0
    var extra_directions: String = ""
    var map_search_description: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStartingDatePicker()
        setEndingDatePicker()
        
        setStartingDateTextField()
        setEndingDateTextField()
        
        setTimeLabels()
        
        startingTimeTextField.inputView = startingDatePicker
        endingTimeTextField.inputView = endingDatePicker
        
    }
    
    
    @IBAction func dropPinButtonPressed(_ sender: Any) {
        //presentHomeStoryboard()
        self.uploadImageToFirebaseStorage()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage() {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let image = pin_image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        let imageReference = Storage.storage().reference().child("/pinImages").child("/\(currentUser.uid)").child("/\(pin_image!)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageReference.putData(imageData, metadata: metaData) { (success, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            imageReference.downloadURL(completion: { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                self.createPinOnFirebase(url: url.absoluteString)
            })
            
            self.presentHomeStoryboard()
        }
    }
    
    func createPinOnFirebase(url: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        var documentReference: DocumentReference!
        var pinData = [String: Any]()
        
        pinData = [
            "pin_title": pin_title,
            "short_description": short_description,
            "pin_photo": url,
            "host_id": currentUser.uid,
            "extra_directions": extra_directions,
            "starting_time": startingTimeTextField.text!,
            "ending_time": endingTimeTextField.text!,
            "latitude": Double(latitude),
            "longitude": Double(longitude),
            "map_search_description": map_search_description,
        ]
        
        documentReference = Firestore.firestore().collection("pins").document()
        
        let data = pinData
        documentReference.setData(data, merge: true) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
        }
    }
    
    
    // Set starting text field to type date/time
    func setStartingDatePicker() {
        startingDatePicker = UIDatePicker()
        startingDatePicker?.datePickerMode = .dateAndTime
        startingDatePicker?.addTarget(self, action: #selector(startingDatePicker(startDatePicker:)), for: .valueChanged)
        startingDatePicker?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    // Set starting text field to type date/time
    @objc func startingDatePicker(startDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        startingTimeTextField.text = dateFormatter.string(from: startDatePicker.date)
    }
    
    
    // Set ending text field to type date/time
    func setEndingDatePicker() {
        endingDatePicker = UIDatePicker()
        endingDatePicker?.datePickerMode = .dateAndTime
        endingDatePicker?.addTarget(self, action: #selector(endingDatePicker(endDatePicker:)), for: .valueChanged)
        endingDatePicker?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    @objc func endingDatePicker(endDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        endingTimeTextField.text = dateFormatter.string(from: endDatePicker.date)
    }
    
    // Automatically add current time to text field
    func setStartingDateTextField() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let dateString = dateFormatter.string(from: date)
        startingTimeTextField.text = dateString
    }
    
    // Automatically add current time to text field
    func setEndingDateTextField() {
        let date = Calendar.current.date(byAdding: .hour, value: +2, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let dateString = dateFormatter.string(from: date!)
        endingTimeTextField.text = dateString
    }
    
    func setTimeLabels() {
        let stringStartDate: String = startingTimeTextField.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let date = dateFormatter.date(from: stringStartDate)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
        let nowDate = Date()
        let textFieldDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
        let currentDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nowDate)
    
        
        if (textFieldDate.day == currentDate.day) {
            self.startTimeLabel.text = "Starting today at: "
        } else if (textFieldDate.day != currentDate.day) {
            self.startTimeLabel.text = "Starting at:"
        }
    }
    
    
    fileprivate func presentHomeStoryboard() {
        let storyboard = UIStoryboard(name: Storyboards.HomeStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: HomeViewControllers.HomeVC)
        present(controller, animated: true, completion: nil)
    }
    
}


