//
//  MainTabBarController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/17.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    // MARK: Properties
    
    let userManager: UserManager = UserManager.sharedInstance
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SceneManager.sharedInstance.mainTabBarController = self
    }
    
    // MARK: Method
    
    func pushNotificationView(newNotification: Wall) {
        guard let viewControllers = viewControllers else {
            return
        }
        let nc = viewControllers[1] as! UINavigationController
        let vc = nc.viewControllers[0] as! NotificationTableViewController
        vc.userNotiList.add(newNotification)
        selectedViewController = nc
    }
}
