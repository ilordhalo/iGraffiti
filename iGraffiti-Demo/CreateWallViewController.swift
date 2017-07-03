//
//  CreateWallViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/8.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class CreateWallTableViewController: UITableViewController, UITextFieldDelegate {
    // MARK: Properties
    
    var uploadButton: UIBarButtonItem?

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var infoField: UITextField!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var repwField: UITextField!
    
    let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return Alamofire.SessionManager(configuration: configuration)
    }()

    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        infoField.delegate = self
        pwField.delegate = self
        repwField.delegate = self
    }
    
    // MARK: IBAction
    
    @IBAction func createWallButtonTouchUpInside(_ sender: Any) {
        guard let user = UserManager.sharedInstance.user else {
            AlertMessage(message: "需登录才能创建墙", viewController: self)
            return
        }
        let uid = user.id!
        let name = nameField.text!
        let info = infoField.text!
        var type = "public"
        switch typeLabel.text! {
        case "公众墙":
            type = "public"
        case "告示墙":
            type = "show"
        case "私人墙":
            type = "personal"
        default: break
        }
        let pw = pwField.text!
        let parameters: Parameters = [
            "name": name,
            "type": type,
            "pw": pw,
            "info": info,
            "uid": String(uid),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["createwall"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    AlertMessage(message: "网络错误", viewController: self)
                }
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            let data = value["ans"] as! String
            DispatchQueue.main.async {
                switch data {
                case "error":
                    AlertMessage(message: "网络错误", viewController: self)
                case "SameWallName":
                    AlertMessage(message: "该名称已存在，请重新输入", viewController: self)
                default:
                    AlertMessage(message: "创建成功", viewController: self, handler: { (UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
    
    // MARK: Storyboard Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "PushWallTypeTableViewController" {
            let vc = segue.destination as! WallTypeTableViewController
            vc.typeLabel = typeLabel
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let ph = textField.placeholder!
        switch ph {
        case "名称":
            infoField.becomeFirstResponder()
        case "密码":
            repwField.becomeFirstResponder()
        default: break
        }
        
        return true
    }
    
}
