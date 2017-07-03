//
//  UserInfoTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/9.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class UserInfoTableViewController: UITableViewController {
    // MARK: Properties
    
    var user: User!
    
    let sessionManager : SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: UIViewController Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let parameters: Parameters = [
            "uid": String(user.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["userinfo"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            let data = value["data"] as! Dictionary<String, Any>
            self.user.dataFrom(dictionary: data)
            DispatchQueue.main.async {
                self.nameLabel.text = self.user.name
                self.dateLabel.text = self.user.date?.description
                self.infoTextView.text = self.user.info
            }
        }
    }
}
