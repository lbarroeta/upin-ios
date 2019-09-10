//
//  PrivacyPolicyVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 9/9/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class PrivacyPolicyVC: UIViewController {

    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: contentLabel.bottomAnchor).isActive = true
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
    
        let text = "\(contentLabel.text!)"    
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
            .foregroundColor: UIColor(white: 0.0, alpha: 1.0),
            .kern: 0.05,
            .paragraphStyle: paragraphStyle
        ]
        
        let font = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        attributedText.addAttribute(.font, value: font, range: NSRange(location: 61, length: 7))
        
        
        contentLabel.attributedText = attributedText
        contentLabel.sizeToFit()
        
    }

   
}
