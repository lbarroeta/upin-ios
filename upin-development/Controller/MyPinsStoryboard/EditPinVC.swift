//
//  EditPinVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/29/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
import JGProgressHUD

class EditPinVC: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var pinImage: UIImageView!
    
    @IBOutlet weak var startingTimeTextField: UITextField!
    @IBOutlet weak var endingTimeTextField: UITextField!
    @IBOutlet weak var extraDirectionsTextField: UITextField!
    @IBOutlet weak var pinTitleNavigationItem: UINavigationItem!
    
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var pinTitleTextField: UITextField!
    @IBOutlet weak var pinTitleCounterLabel: UILabel!
    
    @IBOutlet weak var shortDescriptionTextField: UITextView!
    @IBOutlet weak var shortDescriptionCounterLabel: UILabel!
    @IBOutlet weak var shortDescriptionHeighConstraint: NSLayoutConstraint!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var coordinate: CLLocationCoordinate2D?
    
    var selectedPin = ""
    var selected_latitude: Double = 0.0
    var selected_longitude: Double = 0.0
    var tableView = UITableView()
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var map_search_description: String = ""
    
    let locationManager = CLLocationManager()
    
    private var startingDatePicker: UIDatePicker?
    private var endingDatePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        
        pinListener()
    
        setStartingDatePicker()
        setEndingDatePicker()
        startingTimeTextField.inputView = startingDatePicker
        endingTimeTextField.inputView = endingDatePicker
        
        shortDescriptionTextField.delegate = self
        pinTitleTextField.delegate = self
        
        searchCompleter.delegate = self
        searchTableView.isHidden = true
        
        addressSearchBar.isTranslucent = true
        addressSearchBar.setImage(UIImage(), for: .search, state: .normal)
        
        if let textfield = addressSearchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .lightGray
            textfield.backgroundColor = .none
            
            //textfield.tintColorDidChange()
            textfield.borderStyle = .none
            textfield.textAlignment = .left
            textfield.tintColor = .blue
            textfield.font?.withSize(10)
            
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let pinReference = Firestore.firestore().collection("pins").document(selectedPin)
        guard let image = pinImage.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        let imageReference = Storage.storage().reference().child("/pinImages").child("/\(currentUser.uid)").child("/\(pinImage!)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageReference.putData(imageData, metadata: metaData) { (success, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                self.updateDataToFirebase(url: url.absoluteString)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Updating pin..."
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 5.0)
        uploadImageToFirebaseStorage()
    }
    
    func updateDataToFirebase(url: String) {
        let pinReference = Firestore.firestore().collection("pins").document(selectedPin)
        var pinData = [String: Any]()
        
        pinData = [
            "ending_time": endingTimeTextField.text!,
            "extra_directions": extraDirectionsTextField.text!,
            "latitude": selected_latitude,
            "longitude": selected_longitude,
            "map_search_description": map_search_description,
            "pin_title": pinTitleTextField.text!,
            "short_description": shortDescriptionTextField.text!,
            "starting_time": startingTimeTextField.text!,
            "pin_photo": url
        ]
        
        pinReference.updateData(pinData) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
        }
    }
    
    
    func pinListener() {
        let pinReference = Firestore.firestore().collection("pins").document(selectedPin)
        pinReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            let pin_title = data["pin_title"] as? String
            let starting_time = data["starting_time"] as? String
            let ending_time = data["ending_time"] as? String
            let short_description = data["short_description"] as? String
            let pin_address = data["map_search_description"] as? String
            let extra_directions = data["extra_directions"] as? String
            
            guard let pin_image = data["pin_photo"] as? String else { return }
            guard let pin_image_url = URL(string: pin_image) else { return }
            
            self.pinImage.kf.setImage(with: pin_image_url)
            self.pinTitleTextField.text = pin_title!
            self.startingTimeTextField.text = starting_time!
            self.endingTimeTextField.text = ending_time!
            self.shortDescriptionTextField.text = short_description!
            self.addressSearchBar.text = pin_address!
            self.extraDirectionsTextField.text = extra_directions!
            self.pinTitleNavigationItem.title = "\(pin_title!) Details"
            self.shortDescriptionHeighConstraint.constant = self.shortDescriptionTextField.contentSize.height
            
            let shortDescriptionCharacterCount: String = self.shortDescriptionTextField.text!
            let intShortDescCharacterCounter = Int(shortDescriptionCharacterCount.count)
            self.shortDescriptionCounterLabel.text = "\(intShortDescCharacterCounter)"
            
            let pinTitleCharacterCount: String = self.pinTitleTextField.text!
            let intPinTitleCharacterCounter = Int(pinTitleCharacterCount.count)
            self.pinTitleCounterLabel.text = "\(intPinTitleCharacterCounter)"
        }
    }
    
    @IBAction func editImageButtonPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let galleryOption = UIAlertAction(title: "Gallery", style: .default) { (action) in
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cameraOption = UIAlertAction(title: "Camera", style: .default) { (action) in
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        actionSheet.addAction(cameraOption)
        actionSheet.addAction(galleryOption)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pinImagePicker = info[.originalImage] as? UIImage {
            pinImage.image = pinImagePicker
        }

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
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
    
    func getUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        self.addressSearchBar.text = coordinate.latitude.description
        self.addressSearchBar.endEditing(true)
        self.searchTableView.isHidden = true
        
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (places, error) in
            if error == nil {
                if places != nil {
                    var placemark: CLPlacemark!
                    var components = [String]()
                    
                    placemark = places?.first

                    if let data = placemark.thoroughfare {
                        components.append(data)
                    }
                    
                    if let data = placemark.subLocality {
                        components.append(data)
                    }
                    
                    
                    if let data = placemark.subAdministrativeArea {
                        components.append(data)
                    }
                    
                    if let data = placemark.locality {
                        components.append(data)
                    }
                    
                    if let data = placemark.country {
                        components.append(data)
                    }
                    
                    self.addressSearchBar?.text = components.joined(separator: ", ")
                    self.map_search_description = components.joined(separator: ", ")

                }
            }
        }
        
        self.coordinate = coordinate
    }
    
}


extension EditPinVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == addressSearchBar {
            searchCompleter.queryFragment = searchText
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar == addressSearchBar {
            searchTableView.isHidden = false
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if addressSearchBar.text == "" {
            searchTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == addressSearchBar {
            view.endEditing(true)
        }
    }
    
    
}

extension EditPinVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchTableView.reloadData()
    }
}

extension EditPinVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = searchResults.count
        return count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.item == 0 {
            return self.searchTableView.dequeueReusableCell(withIdentifier: "locationCell")!
        }
        
        let addressCell = UITableViewCell(style: .subtitle, reuseIdentifier: "addressCell")
        let searchResult = searchResults[indexPath.row - 1]
        
        addressCell.textLabel?.text = searchResult.title
        addressCell.detailTextLabel?.text = searchResult.subtitle
        
        return addressCell
    }
}

extension EditPinVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if indexPath.item == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            return getUserLocation()
        }
        
        let completion = searchResults[indexPath.row - 1]
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            let coordinates = response?.mapItems[0].placemark.coordinate
            self.coordinate = coordinates
            
            if response != nil {
                
                var components = [String]()
                
                let placemark = response?.mapItems[0].placemark

                if let data = placemark?.thoroughfare {
                    components.append(data)
                }
                
                if let data = placemark?.subLocality {
                    components.append(data)
                }
                
                if let data = placemark?.subAdministrativeArea {
                    components.append(data)
                }
                if let data = placemark?.locality {
                    components.append(data)
                }
                                
                self.addressSearchBar?.text = components.joined(separator: ", ")
                self.map_search_description = components.joined(separator: ", ")

            }
             
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.addressSearchBar.endEditing(true)
        self.searchTableView.isHidden = true
    }
}

extension EditPinVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: text)
        shortDescriptionCounterLabel.text = "\(0 + updateText.count)"
        return updateText.count <= 300
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if shortDescriptionTextField.textColor == UIColor.lightGray {
            shortDescriptionTextField.text = nil
            shortDescriptionTextField.textColor = .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: 335, height: .max)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}

extension EditPinVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        self.pinTitleCounterLabel.text = "\(0 + updateText.count)"
        return updateText.count <= 35
    }
}
