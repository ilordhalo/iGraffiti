//
//  Pen.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/18.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit

class Pen {
    // MARK: Preperties
    
    var width: CGFloat = 1.0
    var color: UIColor = UIColor.black
    
    // MARK: Initialization
    
    init(width: CGFloat, color: UIColor) {
        self.width = width
        self.color = color
    }
    
    init() {
    }
}
