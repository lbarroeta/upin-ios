//
//  EditUserProfileVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/26/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase

class EditUserProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var otherGenderTextField: UITextField!
    
    
    var interests = [Interests]()
    var listener: ListenerRegistration!
    var userInterests = [String]()
    
    private var birthdatePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 8)]
        segmentedControl.setTitleTextAttributes(font as! [NSAttributedString.Key : Any], for: .normal)
        
    
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setDatePicker()
        birthdateTextField.inputView = birthdatePicker
        
        interestsListener()
        currentUserListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        interests.removeAll()
        collectionView.reloadData()
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            otherGenderTextField.isHidden = true
        case 1:
            otherGenderTextField.isHidden = true
        case 2:
            otherGenderTextField.isHidden = false
        default:
            otherGenderTextField.isHidden = true
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        uploadImageToFirebase()
        
    }
    
    func uploadImageToFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let image = profileImage.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        let imageReference = Storage.storage().reference().child("/userImages").child("/\(currentUser.uid)").child("profileImage.jpg")
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
                self.updateProfileOnFirebase(url: url.absoluteString)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateProfileOnFirebase(url: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserReference = Firestore.firestore().collection("users").document(currentUser.uid)
        var userData = [String: Any]()
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            userData = [
                "gender": "Male",
                "firstName": firstNameTextField.text!,
                "lastName": lastNameTextField.text!,
                "biography": biographyTextView.text!,
                "birthdate": birthdateTextField.text!,
                "profilePictures": [
                    "mainProfileImage": url,
                ]
            ]
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            userData = [
                "gender": "Female",
                "firstName": firstNameTextField.text!,
                "lastName": lastNameTextField.text!,
                "biography": biographyTextView.text!,
                "birthdate": birthdateTextField.text!,
                "profilePictures": [
                    "mainProfileImage": url,
                ]
            ]
        } else {
            userData = [
                "gender": "Other",
                "otherGenderDescription": otherGenderTextField.text!,
                "firstName": firstNameTextField.text!,
                "lastName": lastNameTextField.text!,
                "biography": biographyTextView.text!,
                "birthdate": birthdateTextField.text!,
                "profilePictures": [
                    "mainProfileImage": url,
                ]
            ]
        }
        
        currentUserReference.updateData(userData) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
        }
    }
    
    func currentUserListener() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserReference = Firestore.firestore().collection("users").document(currentUser.uid)
        
        currentUserReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            
            guard let data = snapshot?.data() else { return }
            
            let profileImagePath = data["profilePictures"] as? [String: Any]
            guard let mainProfileImagePath = profileImagePath?["mainProfileImage"] as? String else { return }
            guard let mainProfileImageURL = URL(string: mainProfileImagePath) else { return }
            
            let firstName = data["firstName"] as? String
            let lastName = data["lastName"] as? String
            let gender = data["gender"] as? String
            let birthdate = data["birthdate"] as? String
            let biography = data["biography"] as? String
            let otherGenderDescription = data["otherGenderDescription"] as? String
            self.userInterests = data["interests"] as? Array ?? [""]
            
            self.profileImage.kf.setImage(with: mainProfileImageURL)
            self.firstNameTextField.text = firstName
            self.lastNameTextField.text = lastName
            self.birthdateTextField.text = birthdate
            self.biographyTextView.text = biography
            
            
            
            if gender == "Male" {
                self.segmentedControl.selectedSegmentIndex = 0
            } else if gender == "Female" {
                self.segmentedControl.selectedSegmentIndex = 1
            } else if gender == "Other" {
                self.segmentedControl.selectedSegmentIndex = 2
                self.otherGenderTextField.isHidden = false
                self.otherGenderTextField.text = otherGenderDescription
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func interestsListener() {
        Firestore.firestore().collection("interests").whereField("is_active", isEqualTo: true).order(by: "name", descending: false).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            snapshot?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let interest = Interests.init(data: data)
                
                switch change.type {
                case .added:
                    self.onInterestAdded(change: change, interest: interest)
                case .modified:
                    self.onInterestModified(change: change, interest: interest)
                case .removed:
                    self.onInterestRemoved(change: change)
                }
            })
        })
    }
    
    func setDatePicker() {
        birthdatePicker = UIDatePicker()
        birthdatePicker?.datePickerMode = .date
        birthdatePicker?.addTarget(self, action: #selector(dateChanged(birthdatePicker:)), for: .valueChanged)
        birthdatePicker?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    @objc func dateChanged(birthdatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        birthdateTextField.text = dateFormatter.string(from: birthdatePicker.date)
    }
    
    @IBAction func editPictureButtonPressed(_ sender: Any) {
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
        if let profileImagePicker = info[.originalImage] as? UIImage {
            profileImage.image = profileImagePicker
        }

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

extension EditUserProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func onInterestAdded(change: DocumentChange, interest: Interests) {
        let newIndex = Int(change.newIndex)
        interests.insert(interest, at: newIndex)
        collectionView.insertItems(at: [IndexPath.init(item: newIndex, section: 0)])
    }
    
    func onInterestModified(change: DocumentChange, interest: Interests) {
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            interests[index] = interest
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            interests.remove(at: oldIndex)
            interests.insert(interest, at: newIndex)
            
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onInterestRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        interests.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath.init(item: oldIndex, section: 0)])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProfileInterestCell", for: indexPath) as? EditProfileInterestCell {
            
            let fireBaseInterest = interests[indexPath.item]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !self.userInterests.contains(fireBaseInterest.name) {
                    cell.interestNameLabel.textColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
                    cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    cell.mainBackgroundView.layer.borderWidth = 0.5
                    cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
                    cell.mainBackgroundView.layer.cornerRadius = 15
                } else {
                    cell.interestNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
                    cell.mainBackgroundView.layer.cornerRadius = 15
                }
            }
                       
            cell.configureCell(interests: interests[indexPath.item])
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    
}



