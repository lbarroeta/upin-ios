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

class StepThreeVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var pinLocationTextField: UITextField!
    @IBOutlet weak var extraDirectionsTextField: UITextField!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    
    var tableView = UITableView()
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    // Segue variables
    var pin_title = ""
    var short_description = ""
    var pinImage: UIImage!
    var map_search_description : String = ""
    
    
    let hud = JGProgressHUD(style: .dark)
    let locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinLocationTextField.delegate = self
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if pinLocationTextField.text == "" {
            self.simpleAlert(title: "Error", msg: "You must add a location...")
        } else {
            self.performSegue(withIdentifier: "ToStepFourVC", sender: self)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! StepFourVC
        vc.pin_title = pin_title
        vc.short_description = short_description
        vc.pin_image = pinImage
        vc.map_search_description = map_search_description
        if let double = coordinate?.latitude {
            vc.latitude = double
        }
        
        if let double = coordinate?.longitude {
            vc.longitude = double
        }
        
        vc.extra_directions = extraDirectionsTextField.text!
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
        pinLocationTextField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        map_search_description = tableView.cellForRow(at: indexPath)?.textLabel?.text ?? ""
        let selectedResult = matchingItems[indexPath.row]
        let latitude : Double? = selectedResult.placemark.coordinate.latitude
        let longitude : Double? = selectedResult.placemark.coordinate.longitude
        coordinate = selectedResult.placemark.coordinate
        animateTableView(shouldShow: false)
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
