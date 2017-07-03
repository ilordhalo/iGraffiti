//
//  SignUpTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/11.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

protocol SignUpDelegate: class {
    var response: String {get set}
    func signUpFinished()
}

class SignUpTableViewController: UITableViewController, SignUpDelegate, UITextFieldDelegate {
    var response: String = ""

    // MARK: Properties
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var infoField: UITextField!
    
    @IBOutlet weak var pwField: UITextField!
    
    @IBOutlet weak var repwField: UITextField!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameField.delegate = self
        infoField.delegate = self
        pwField.delegate = self
        repwField.delegate = self
        UserManager.sharedInstance.signUpDelegate = self
    }
    
    // MARK: IBAction
    
    @IBAction func signUpButtonTouchUpInside(_ sender: UIButton) {
        userNameField.resignFirstResponder()
        infoField.resignFirstResponder()
        pwField.resignFirstResponder()
        repwField.resignFirstResponder()
        let un = userNameField.text!
        let pw = pwField.text!
        let repw = repwField.text!
        let info = infoField.text!
        if pw != repw {
            AlertMessage(message: "两次密码输入不一样", viewController: self)
            return
        }
        else if un == "" {
            AlertMessage(message: "用户名不能为空", viewController: self)
            return
        }
        else if pw == "" {
            AlertMessage(message: "密码不能为空", viewController: self)
            return
        }
        UserManager.sharedInstance.signUp(userName: un, password: pw, info: info)
    }
    
    // MARK: SignUpDelegate
    
    func signUpFinished() {
        switch response {
        case "error":
            AlertMessage(message: "网络错误", viewController: self)
        case "SameUserName":
            AlertMessage(message: "用户名已使用，请重新输入",viewController: self)
        case "success":
            AlertMessage(message: "注册成功", viewController: self, handler: { (UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
            })
        default:
            return
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let ph = textField.placeholder!
        switch ph {
        case "用户名":
            infoField.becomeFirstResponder()
        case "介绍":
            pwField.becomeFirstResponder()
        case "密码":
            repwField.becomeFirstResponder()
        default: break
        }
        return true
    }
}
