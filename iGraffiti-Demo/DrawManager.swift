//
//  DrawToolsManager.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/18.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit

enum DrawToolsType {
    case pen
    case eraser
}

class DrawManager {
    // MARK: Properties
    
    var toolsType: DrawToolsType!
    var pen: Pen = Pen()
    var eraser: Eraser = Eraser()
    var curves: NSMutableArray!
    var recurves: NSMutableArray!
    
    // MARK: Initialization
    
    init() {
        curves = NSMutableArray()
        recurves = NSMutableArray()
        toolsType = .pen
    }
    
    // MARK: Method
    
    func usePen(width: CGFloat, color: UIColor) {
        toolsType = .pen
        pen.width = width
        pen.color = color
    }
    
    func useEraser(width: CGFloat) {
        toolsType = .eraser
        eraser.width = width
    }
    
    func drawLine() -> DrawLine {
        let drawLine = DrawLine()
        drawLine.type = toolsType
        switch toolsType! {
        case .pen:
            drawLine.color = pen.color
            drawLine.width = pen.width
        case .eraser:
            drawLine.width = eraser.width
        }
        return drawLine
    }
    
}
