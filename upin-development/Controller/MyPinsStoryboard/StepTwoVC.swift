//
//  StepTwoVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/11/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class StepTwoVC: UIViewController {

    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    let hud = JGProgressHUD(style: .dark)
    
    var pin_title = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(pin_title)
        
        let pinImageTap = UITapGestureRecognizer(target: self, action: #selector(pinImageTapped(_:)))
        pinImageTap.numberOfTapsRequired = 1
        pinImage.isUserInteractionEnabled = true
        pinImage.addGestureRecognizer(pinImageTap)
    }
    
    @objc func pinImageTapped(_ tap: UITapGestureRecognizer) {
        launchImagePicker()
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToStepThreeVC", sender: self)
    }
    
    func uploadImageToFirebaseStorage() {
        guard let image = pinImage.image else { return }
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
            "pin_title": pin_title
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! StepThreeVC
        vc.testImage = pinImage.image
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension StepTwoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        pinImage.contentMode = .scaleToFill
        pinImage.image = image
        
        if pinImage.image == image {
            self.skipButton.title = "Next"
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pinImage.image = UIImage(named: "profilePicLogo")
        if pinImage.image == UIImage(named: "profilePicLogo") {
            self.skipButton.title = "Skip"
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}
