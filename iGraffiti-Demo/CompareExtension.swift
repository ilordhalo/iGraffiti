//
//  CompareExtension.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/2.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

func <(left: CGSize, right: CGSize) -> Bool {
    if left.width < right.width || left.height < right.height {
        return true
    }
    return false
}
