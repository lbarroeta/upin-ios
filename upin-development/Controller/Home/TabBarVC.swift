//
//  TabBarVC.swift
//  upin-development
//
//  Created by Leonardo Barroeta on 8/29/19.
//  Copyright © 2019 Kodim. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    
    private var lastTab: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // Set default tab
        selectedIndex = Tabs.home.index
        lastTab = Tabs.home.index
    
    }
    
    
    enum Tabs: String {
        case profile = "Profile"
        case pins = "My pins"
        case home = "Home"
        case notifications = "Notifications"
        case settings = "Settings"
        
        var index: Int {
            switch self {
                case .profile: return 0
                case .pins: return 1
                case .home: return 2
                case .notifications: return 3
                case .settings: return 4
            }
        }
        
    }

}
