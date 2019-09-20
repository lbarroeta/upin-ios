//
//  MyPinsVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class MyPinsVC: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pinMessageLabel: UILabel!
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var joinedView: UIView!
    @IBOutlet weak var requestedView: UIView!
    @IBOutlet weak var previousView: UIView!
    
    var myPins = [Pins]()
    var listener: ListenerRegistration!
    var selectedPin: Pins!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pinListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
        myPins.removeAll()
        tableView.reloadData()
    }
    
    @IBAction func createPinButtonPressed(_ sender: Any) {
        presentCreatePinsStoryboard()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func pinListener() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        listener = Firestore.firestore().collection("pins").whereField("host_id", isEqualTo: currentUser.uid).addSnapshotListener { (snapshot, error) in
            
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            let snapshotCount = snapshot?.documents.count
            
            if snapshotCount == 0 {
                self.pinMessageLabel.text = "You are currently not hosting any pins. Create a pin by tapping on the plus sign."
            } else {
                self.pinMessageLabel.isHidden = true
            }
            
            snapshot?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let pin = Pins.init(data: data)
                
                switch change.type {
                case .added:
                    self.onPinAdded(change: change, myPin: pin)
                case .modified:
                    self.onPinModified(change: change, myPin: pin)
                case .removed:
                    self.onPinRemoved(change: change)
                }
            })
            
        }
    }
    
    @IBAction func setViewToPresent(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            currentView.alpha = 1
            joinedView.alpha = 0
            requestedView.alpha = 0
            previousView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            currentView.alpha = 0
            joinedView.alpha = 0
            requestedView.alpha = 0
            previousView.alpha = 0
        } else if sender.selectedSegmentIndex == 2 {
            currentView.alpha = 0
            joinedView.alpha = 1
            requestedView.alpha = 0
            previousView.alpha = 0
        } else if sender.selectedSegmentIndex == 3 {
            joinedView.alpha = 0
            currentView.alpha = 0
            requestedView.alpha = 1
            previousView.alpha = 0
        } else if sender.selectedSegmentIndex == 4 {
            joinedView.alpha = 0
            currentView.alpha = 0
            requestedView.alpha = 0
            previousView.alpha = 1
        }
    }
    
    fileprivate func presentCreatePinsStoryboard() {
        let storyboard = UIStoryboard(name: Storyboards.MyPinsStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: MyPinsViewControllers.StepOneVC)
        present(controller, animated: true, completion: nil)
    }
    
}

extension MyPinsVC: UITableViewDelegate, UITableViewDataSource {
    
    func onPinAdded(change: DocumentChange, myPin: Pins) {
        let newIndex = Int(change.newIndex)
        myPins.insert(myPin, at: newIndex)
        tableView.insertRows(at: [IndexPath.init(item: newIndex, section: 0)], with: .automatic)
    }
    
    func onPinModified(change: DocumentChange, myPin: Pins) {
        if change.newIndex == change.oldIndex {
            // Item changed, but remained in the same position.
            let index = Int(change.newIndex)
            myPins[index] = myPin
            tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        } else {
            // Item changed and changed the position.
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            myPins.remove(at: oldIndex)
            myPins.insert(myPin, at: newIndex)
            
            tableView.moveRow(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onPinRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        myPins.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath.init(item: oldIndex, section: 0)], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as? MyPinsCell {
            cell.configureCell(myPins: myPins[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPin = myPins[indexPath.item]
        performSegue(withIdentifier: "ToNotificationPinDetailVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToNotificationPinDetailVC" {
            if let destination = segue.destination as? NotificationsPinDetailVC {
                destination.selectedPin = selectedPin
            }
        }
    }
    
    
}
