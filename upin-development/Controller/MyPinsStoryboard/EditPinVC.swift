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

class EditPinVC: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinTitleTextField: UITextField!
    @IBOutlet weak var startingTimeTextField: UITextField!
    @IBOutlet weak var endingTimeTextField: UITextField!
    @IBOutlet weak var scrollingDescriptionTextField: UITextView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var extraDirectionsTextField: UITextField!
    @IBOutlet weak var pinTitleNavigationItem: UINavigationItem!
    
    var selectedPin = ""
    var coordinate: CLLocationCoordinate2D?
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
        setStartingDatePicker()
        setEndingDatePicker()
        
        
        startingTimeTextField.inputView = startingDatePicker
        endingTimeTextField.inputView = endingDatePicker
        
        addressTextField.delegate = self

        pinListener()
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
            "short_description": scrollingDescriptionTextField.text!,
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
        var pinReference = Firestore.firestore().collection("pins").document(selectedPin)
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
            self.scrollingDescriptionTextField.text = short_description!
            self.addressTextField.text = pin_address!
            self.extraDirectionsTextField.text = extra_directions!
            self.pinTitleNavigationItem.title = "\(pin_title!) Details"
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
    
}

extension EditPinVC: MKMapViewDelegate {
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = addressTextField.text
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            } else if response!.mapItems.count == 0 {
                print("No results")
            } else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem as MKMapItem)
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension EditPinVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == addressTextField {
            tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40, height: view.frame.height - 170)
            tableView.layer.cornerRadius = 5.0
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
            
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.tag = 1
            tableView.rowHeight = 60
            
            view.addSubview(tableView)
            
            animateTableView(shouldShow: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addressTextField {
            performSearch()
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if addressTextField.text == "" {
            animateTableView(shouldShow: false)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = []
        tableView.reloadData()
        animateTableView(shouldShow: false)
        return true
    }
    
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame = CGRect(x: 20, y: 660, width: self.view.frame.width - 20, height: self.view.frame.height - 50)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: self.view.frame.height - 50)
            }) { (finished) in
                for subview in self.view.subviews {
                    if subview.tag == 1 {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}

extension EditPinVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "LocationCell")
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressTextField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        map_search_description = tableView.cellForRow(at: indexPath)?.textLabel?.text ?? ""
        let selectedResult = matchingItems[indexPath.row]
        let latitude : Double? = selectedResult.placemark.coordinate.latitude
        let longitude : Double? = selectedResult.placemark.coordinate.longitude
        coordinate = selectedResult.placemark.coordinate
        selected_latitude = selectedResult.placemark.coordinate.latitude
        selected_longitude = selectedResult.placemark.coordinate.longitude
        animateTableView(shouldShow: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if addressTextField.text == "" {
            animateTableView(shouldShow: false)
        }
    }
}
