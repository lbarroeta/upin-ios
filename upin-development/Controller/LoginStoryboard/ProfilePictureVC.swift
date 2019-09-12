//
//  ProfilePictureVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/28/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class ProfilePictureVC: UIViewController {

    @IBOutlet weak var mainProfileImage: UIImageView!
    @IBOutlet weak var firstProfileImage: UIImageView!
    @IBOutlet weak var secondProfileImage: UIImageView!
    @IBOutlet weak var thirdProfileImage: UIImageView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let firstImageTap = UITapGestureRecognizer(target: self, action: #selector(firstImageTapped(_:)))
        firstImageTap.numberOfTapsRequired = 1
        firstProfileImage.isUserInteractionEnabled = true
        firstProfileImage.addGestureRecognizer(firstImageTap)
        
    }
    
    @objc func firstImageTapped(_ tap: UITapGestureRecognizer) {
        launchImagePicker()
    }
    
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.hud.textLabel.text = "Uploading image..."
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 5.0)
        uploadImageToFirebaseStorage()
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage() {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let image = firstProfileImage.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        let imageReference = Storage.storage().reference().child("/userImages").child("/\(currentUser.uid)").child("profileImage.jpg")
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
                    print(error.localizedDescription)
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
        var userData = [String: Any]()
        userData = [
            "profilePictures": [
                "mainProfileImage": url,
                "secondProfileImage": "",
                "thirdProfileImage": ""
            ]
        ]
        
        documentReference = Firestore.firestore().collection("users").document(currentUser.uid)
        
        let data = userData
        documentReference.setData(data, merge: true) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "BiographyVC", sender: nil)
        }
    }

}

extension ProfilePictureVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
    
        firstProfileImage.contentMode = .scaleAspectFill
        firstProfileImage.image = image
        mainProfileImage.image = image
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
