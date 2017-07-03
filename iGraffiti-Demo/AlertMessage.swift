//
//  AlertMessage.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/11.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

func AlertMessage(message: String, viewController controller: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
    let alertView = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "确定", style: .default, handler: handler)
    alertView.addAction(okAction)
    controller.present(alertView, animated: true, completion: nil)
}
