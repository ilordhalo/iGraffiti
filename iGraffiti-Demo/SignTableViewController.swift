//
//  SignTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/11.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

protocol SignInDelegate: class {
    func signInFinished(message: String)
}

class SignTableViewController: UITableViewController, SignInDelegate, UITextFieldDelegate {
    // MARK: Properties
    
    @IBOutlet weak var pwField: UITextField!
    
    @IBOutlet weak var userNameField: UITextField!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameField.delegate = self
        pwField.delegate = self
        UserManager.sharedInstance.signInDelegate = self
    }
    
    // MARK: IBAction
    
    @IBAction func loginButtonTouchUpInside(_ sender: UIButton) {
        userNameField.resignFirstResponder()
        pwField.resignFirstResponder()
        let un = userNameField.text!
        let pw = pwField.text!
        if un == "" {
            AlertMessage(message: "用户名不能为空", viewController: self)
        }
        else if pw == "" {
            AlertMessage(message: "密码不能为空", viewController: self)
        }
        UserManager.sharedInstance.signIn(userName: un, password: pw)
    }
    
    // MARK: SignInDelegate
    
    func signInFinished(message: String) {
        switch message {
        case "error":
            AlertMessage(message: "网络错误", viewController: self)
        case "empty":
            AlertMessage(message: "用户名或密码错误", viewController: self)
        case "success":
            AlertMessage(message: "登录成功", viewController: self, handler: { (UIApplication) in
                self.navigationController?.popViewController(animated: true)
            })
        default: break
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let ph = textField.placeholder!
        if ph == "用户名" {
            pwField.becomeFirstResponder()
        }
        return true
    }
}
