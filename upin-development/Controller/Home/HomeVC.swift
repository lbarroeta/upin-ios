//
//  HomeVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/29/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import FittedSheets

class HomeVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinDetailview: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBar: UINavigationBar!
    
    let locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var pins = [String: [String: Any]]()
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        navBar.layer.borderColor = .none
        
        pinListener()
        

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            centerMapOnUserLocation()
        }
        
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: true)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            centerMapOnUserLocation()
            mapView.showsUserLocation = false
            mapView.addAnnotations(mapView.annotations)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserService.userListener == nil {
            UserService.getCurrentUserInfo()
            self.centerMapOnUserLocation()
            mapView.showsUserLocation = false
            mapView.addAnnotations(mapView.annotations)
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: Storyboards.MessageStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ConversationsVC")
        present(controller, animated: true, completion: nil)
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsUserLocation = false
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    func pinListener() {
        let pinReference = Firestore.firestore().collection("pins")
        pinReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                for document in snapshot!.documents {
                    let annotations = MKPointAnnotation()
                    let data: [String: Any] = document.data()
                    guard let latitude = data["latitude"] as? Double else { return }
                    guard let longitude = data["longitude"] as? Double else { return }
                    
                    annotations.coordinate.latitude = latitude
                    annotations.coordinate.longitude = longitude
                    
                    self.pins["\(latitude)-\(longitude)"] = data
                    self.mapView.addAnnotation(annotations)
                }
            }
        }
    
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = UIStoryboard(name: "MyPins", bundle: nil).instantiateViewController(withIdentifier: "PinHomeDetailVC") as! PinHomeDetailVC
        guard let longitude = view.annotation?.coordinate.longitude, let latitude = view.annotation?.coordinate.latitude else { return }
        let id = "\(latitude)-\(longitude)"
        guard let data = pins[id] else { return }
        
    
        controller.pin_latitude = String(data["latitude"] as! Double)
        controller.pin_longitude = String(data["longitude"] as! Double)
        controller.pin_title = data["pin_title"] as? String
        controller.pin_description = data["short_description"] as? String
        controller.pin_ending_time = data["ending_time"] as? String
        controller.pin_starting_time = data["starting_time"] as? String
        controller.pin_image = data["pin_photo"] as? String
        controller.pin_host_id = data["host_id"] as? String
        controller.map_search_description = data["map_search_description"] as? String
        
        let sheetController = SheetViewController(controller: controller, sizes: [.fixed(410)])
        present(sheetController, animated: false, completion: nil)
    }
    
}

