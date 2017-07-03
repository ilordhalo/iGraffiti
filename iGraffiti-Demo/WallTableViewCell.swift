//
//  WallTableViewCell.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/9.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

class WallTableViewCell: UITableViewCell {
    // MARK: Properties
    
    var wall: Wall! {
        didSet {
            self.textLabel?.text = wall.name
        }
    }
    let identifier = "WallTableViewCell"
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init() {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        self.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
        self.selectionStyle = UITableViewCellSelectionStyle.default
    }
    
    // MARK: Storyboard Method
    
    func pushDetailView(pusher: UIViewController) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WallInfoTableViewController") as! WallInfoTableViewController
        viewController.hidesBottomBarWhenPushed = true
        viewController.wall = wall.copy() as! Wall
        pusher.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushWallView() {
        guard let viewControllers = SceneManager.sharedInstance.mainTabBarController.viewControllers else {
            return
        }
        WallManager.sharedInstance.wall = wall
        SceneManager.sharedInstance.mainTabBarController.selectedViewController = viewControllers[0] as! UINavigationController
    }
}
