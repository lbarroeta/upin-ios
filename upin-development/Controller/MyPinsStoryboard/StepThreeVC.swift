//
//  StepThreeVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import CoreLocation
import MapKit

class StepThreeVC: UIViewController {

    @IBOutlet weak var pinLocationTextField: UITextField!
    @IBOutlet weak var extraDirectionsTextField: UITextField!
    @IBOutlet weak var segueImage: UIImageView!
    
    var testImage: UIImage!
    
    var tableView = UITableView()
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pinLocationTextField.delegate = self
        
        segueImage.image = testImage
        segueImage.isHidden = true
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        uploadImageToFirebaseStorage()
        //self.performSegue(withIdentifier: "ToStepFourVC", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage() {
        guard let image = segueImage.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        let imageReference = Storage.storage().reference().child("/pinImages")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imageReference.putData(imageData, metadata: metaData) { (success, error) in
            if let error = error {
                self.hud.isHidden = true
                print(error.localizedDescription)
                return
            }
            
            imageReference.downloadURL(completion: { (url, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                self.uploadImageToFirebaseFirestore(url: url.absoluteString)
            })
        }
    }
    
    func uploadImageToFirebaseFirestore(url: String) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        var documentReference: DocumentReference!
        
        var pinData = [String: Any]()
        
        pinData = [
            "pin_photo": url,
            "host_id": currentUser.uid
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
    
}

extension StepThreeVC: MKMapViewDelegate {
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = pinLocationTextField.text
        
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

extension StepThreeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == pinLocationTextField {
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
        if textField == pinLocationTextField {
            performSearch()
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if pinLocationTextField.text == "" {
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
                self.tableView.frame = CGRect(x: 20, y: 280, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
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

extension StepThreeVC: UITableViewDelegate, UITableViewDataSource {
    
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
        animateTableView(shouldShow: false)
        print("selected")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if pinLocationTextField.text == "" {
            animateTableView(shouldShow: false)
        }
    }
}
