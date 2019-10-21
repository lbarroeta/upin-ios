//
//  EditUserProfileVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/26/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class EditUserProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var otherGenderTextField: UITextField!
        
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var birthdateChangeFirstLabel: UILabel!
    @IBOutlet weak var birthdateChangeCounterLabel: UILabel!
    @IBOutlet weak var birthdateChangeLastLabel: UILabel!
    
    @IBOutlet weak var biographyTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var biographyCounterLabel: UILabel!
    
    var interests = [Interests]()
    var userCurrentInterests = [Interests]()
    var userInterestsNames = [String]()
    var listener: ListenerRegistration!
    var userInterests = [String]()
    var birthdayChanged = false
    var birthdayChangeFirebaseCounter: NSNumber = 0.0
    var userBirthdate = ""
    
    let hud = JGProgressHUD(style: .dark)
    
    private var birthdatePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 8)]
        segmentedControl.setTitleTextAttributes(font as? [NSAttributedString.Key : Any], for: .normal)
        
        biographyTextView.delegate = self
    
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setDatePicker()
        birthdateTextField.inputView = birthdatePicker
        
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
        
        self.hud.textLabel.text = "Updating your profile..."
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 1.5, animated: true)
        
        uploadImageToFirebase()
    }
    
   
    @IBAction func birthdateTextFieldChanged(_ sender: UITextField) {
        if self.birthdateTextField.text != self.userBirthdate {
            // Birthdate changed
            self.birthdayChanged = true
        } else {
            // Birthdate didn't changed
            self.birthdayChanged = false
        }
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
        
        if (self.segmentedControl.selectedSegmentIndex == 0)  {
            userData = [
                "gender": "Male",
                "firstName": firstNameTextField.text!,
                "lastName": lastNameTextField.text!,
                "biography": biographyTextView.text!,
                "birthdate": birthdateTextField.text!,
                "birthdate_change_count": 1,
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
        
        // Updating the rest of the data
        currentUserReference.updateData(userData) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
        }
        
        // Updating birthdate change counter
        if birthdayChanged == true {
            currentUserReference.updateData([
                "birthdate_change_counter": Int(truncating: self.birthdayChangeFirebaseCounter) + 1
            ])
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
            let birthdate_change_counter = data["birthdate_change_counter"] as? NSNumber
            let biography = data["biography"] as? String
            let otherGenderDescription = data["otherGenderDescription"] as? String
            self.userInterests = data["interests"] as? Array ?? [""]
            self.userInterestsNames = data["interests"] as? Array ?? [""]
            self.collectionView.reloadData()
            
            self.profileImage.kf.setImage(with: mainProfileImageURL)
            self.firstNameTextField.text = firstName
            self.lastNameTextField.text = lastName
            
            
            self.biographyTextView.text = biography
            self.biographyTextViewHeightConstraint.constant = self.biographyTextView.contentSize.height
            
            self.birthdateTextField.text = birthdate
            self.birthdayChangeFirebaseCounter = birthdate_change_counter!
            self.birthdateChangeCounterLabel.text = String(3 - Int(truncating: self.birthdayChangeFirebaseCounter))
            self.userBirthdate = birthdate!
            
            // Counting the characters coming from database for biography, so we can set the counter label from start.
            let biographyCharacterCount: String = self.biographyTextView.text!
            let intbiographyCharacterCount = Int(biographyCharacterCount.count)
            self.biographyCounterLabel.text = "\(intbiographyCharacterCount)"
            
            //Setting the segmented control based on the gender from database
            if gender == "Male" {
                self.segmentedControl.selectedSegmentIndex = 0
            } else if gender == "Female" {
                self.segmentedControl.selectedSegmentIndex = 1
            } else if gender == "Other" {
                self.segmentedControl.selectedSegmentIndex = 2
                self.otherGenderTextField.isHidden = false
                self.otherGenderTextField.text = otherGenderDescription
            }
            
            // Setting the message based on the birthdate change counter
            if self.birthdayChangeFirebaseCounter == 3 {
                self.birthdateTextField.isEnabled = false
                self.birthdateChangeFirstLabel.text = "You've reached the maximum of birthdate changes"
                self.birthdateChangeCounterLabel.isHidden = true
                self.birthdateChangeLastLabel.isHidden = true
            } else if self.birthdayChangeFirebaseCounter == 2 {
                self.birthdateTextField.isEnabled = true
                self.birthdateChangeFirstLabel.text = "You can only change your birthdate"
                self.birthdateChangeCounterLabel.isHidden = false
                self.birthdateChangeLastLabel.isHidden = false
                self.birthdateChangeLastLabel.text = "more time"
            } else if self.birthdayChangeFirebaseCounter == 1 {
                self.birthdateTextField.isEnabled = true
                self.birthdateChangeFirstLabel.text = "You can only change your birthdate"
                self.birthdateChangeCounterLabel.isHidden = false
                self.birthdateChangeLastLabel.isHidden = false
                self.birthdateChangeLastLabel.text = "more times"
            } else if self.birthdayChangeFirebaseCounter == 0 {
                self.birthdateTextField.isEnabled = true
                self.birthdateChangeFirstLabel.text = "You can only change your birthdate"
                self.birthdateChangeCounterLabel.isHidden = false
                self.birthdateChangeLastLabel.isHidden = false
                self.birthdateChangeLastLabel.text = "more times"
            }
            
        }
        
        self.collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userInterestsNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditUserProfileInterests", for: indexPath) as! ProfileInterestsCell
        cell.interestsLabel.text = userInterestsNames[indexPath.item]
       
        if indexPath.item == 0 {
            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
            cell.counterBackgroundView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.counterBackgroundView.layer.cornerRadius = 10
            
            cell.counterBackgroundView.isHidden = false
            
            cell.interestsCountLabel.textColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsCountLabel.text = "1"
        } else if indexPath.item == 1 {
            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
            cell.counterBackgroundView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.counterBackgroundView.layer.cornerRadius = 10
            
            cell.counterBackgroundView.isHidden = false
            cell.interestsCountLabel.textColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsCountLabel.text = "2"
        } else if indexPath.item == 2 {

            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

            cell.counterBackgroundView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.counterBackgroundView.layer.cornerRadius = 10
            
            cell.counterBackgroundView.isHidden = false
            cell.interestsCountLabel.textColor = #colorLiteral(red: 0.9327976704, green: 0.7618982792, blue: 0.1620329022, alpha: 1)
            cell.interestsCountLabel.text = "3"
            
        } else if 3...7 ~= indexPath.item {
            cell.mainBackgroundView.layer.borderColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.mainBackgroundView.layer.cornerRadius = 20
            cell.mainBackgroundView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.interestsLabel.textColor = #colorLiteral(red: 0.3724012077, green: 0.8648856878, blue: 0.6968715191, alpha: 1)
            cell.counterBackgroundView.isHidden = true
        }
        
        return cell
    }
    
}

extension EditUserProfileVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           let currentText = textView.text ?? ""
           guard let stringRange = Range(range, in: currentText) else {
               return false
           }
           
           let updateText = currentText.replacingCharacters(in: stringRange, with: text)
           biographyCounterLabel.text = "\(0 + updateText.count)"
           return updateText.count <= 300
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

