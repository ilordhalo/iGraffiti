//
//  WallInfoTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/9.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class WallInfoTableViewController: UITableViewController {
    // MAKR: Properties
    
    var wall: Wall!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    let sessionManager : SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return Alamofire.SessionManager(configuration: configuration)
    }()

    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: IBAction
    
    @IBAction func showButtonTouchUpInside(_ sender: UIButton) {
        guard let userID = wall.userID else {
            return
        }
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UserInfoTableViewController") as! UserInfoTableViewController
        viewController.hidesBottomBarWhenPushed = true
        viewController.user = User.init(id: userID, name: "")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: UIViewController Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let parameters: Parameters = [
            "target": String(wall.id),
            "password": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["walldata"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            let data = value["data"] as! Dictionary<String, Any>
            self.wall.dataFrom(dictionary: data)
            DispatchQueue.main.async {
                self.nameLabel.text = self.wall.name
                self.typeLabel.text = self.wall.type.description
                self.infoTextView.text = self.wall.info
            }
        }
    }
}
