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
    
    // Segue variables
    var pin_title = ""
    var short_description = ""
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! StepThreeVC
        vc.pinImage = pinImage.image
        vc.pin_title = pin_title
        vc.short_description = short_description
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
