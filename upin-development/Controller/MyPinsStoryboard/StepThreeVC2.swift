//
//  StepThreeVC2.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 10/16/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StepThreeVC2: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var coordinate: CLLocationCoordinate2D?
    
    
    // Segue variables
    var pinImage: UIImage!
    var pin_title = ""
    var short_description = ""
    var map_search_description = ""

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var extraDirectionsTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topButton = UIButton()
        self.searchTableView.tableHeaderView = topButton

        searchCompleter.delegate = self
        
        searchTableView.isHidden = true
        
        addressSearchBar.isTranslucent = true
        addressSearchBar.setImage(UIImage(), for: .search, state: .normal)
        
        if let textfield = addressSearchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if addressSearchBar.text == "" {
            self.simpleAlert(title: "Error", msg: "You must add a location...")
        } else {
            self.performSegue(withIdentifier: "ToStepFourVC", sender: self)
        }
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

extension StepThreeVC2: UISearchBarDelegate {
    
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

extension StepThreeVC2: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchTableView.reloadData()
    }
}

extension StepThreeVC2: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = searchResults.count ?? 0
        return count + 1
        //return searchResults.count
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

extension StepThreeVC2: UITableViewDelegate {
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
                if let data = placemark?.country {
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
