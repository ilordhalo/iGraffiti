//
//  DrawTableView.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/18.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit

class DrawTableView: UIView {
    // MARK: Properties
    
    lazy var drawManager: DrawManager = {
        return DrawManager()
    }()
    var gestureRecognizer: UIGestureRecognizer!
    var lastFrame: CGRect!
    var firstDrawing: Bool = true
    
    override var frame: CGRect {
        didSet {
            changeCurvesPoint()
            lastFrame = frame
        }
    }
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        lastFrame = self.frame
        gestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(onDrag))
        addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: Drawing Control
    
    func resetDrawing() {
        drawManager.curves.removeAllObjects()
        drawManager.recurves.removeLastObject()
        setNeedsDisplay()
    }
    
    func undoDraw() {
        guard let lastDraw = drawManager.curves.lastObject else {
            return
        }
        drawManager.recurves.add(lastDraw)
        drawManager.curves.removeLastObject()
        setNeedsDisplay()
    }
    
    func redoDraw() {
        guard let lastRemovedDraw = drawManager.recurves.lastObject else {
            return
        }
        drawManager.curves.add(lastRemovedDraw)
        drawManager.recurves.removeLastObject()
        setNeedsDisplay()
    }
    
    func currentImage() -> UIImage? {
        /* Get image from current context */
        let frame = self.frame
        UIGraphicsBeginImageContext(frame.size)
        let cref = UIGraphicsGetCurrentContext()
        self.layer.render(in: cref!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        /* Get bitmap info from image */
        let imgWidth = Int(frame.width)
        let imgHeight = Int(frame.height)
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let imgData = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: imgHeight*imgWidth*4)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bmpContext = CGContext(data: imgData, width: imgWidth, height: imgHeight, bitsPerComponent: 8, bytesPerRow: imgWidth*4, space: colorSpace,  bitmapInfo: bitmapInfo.rawValue)
        bmpContext?.draw((image?.cgImage!)!, in: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        /* Change bitmap data */
        for i in 0 ..< imgWidth*imgHeight {
            if imgData[i*4+1] == 255 && imgData[i*4+2] == 255 && imgData[i*4+3] == 255 {
                imgData[i*4]=0
            }
        }
        let data = bmpContext?.data
        
        guard data != nil else {
            fatalError("EmptyDataError")
        }
        
        
        /* Create image from bitmap info */
        let bitmapContext = CGContext(data: imgData, width: imgWidth, height: imgHeight, bitsPerComponent: 8, bytesPerRow: imgWidth*4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        guard bitmapContext != nil else {
            fatalError("BitmapContextError")
        }
        
        let imageRef = bitmapContext?.makeImage()
        let saveImage = UIImage.init(cgImage: imageRef!)
        let newImageData = UIImagePNGRepresentation(saveImage)
        let newImage = UIImage.init(data: newImageData!)
        
        return newImage
    }
    
    // MARK: Drawing Method
    
    func onDrag() {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let drawLine = drawManager.drawLine()
            drawManager.curves.add(drawLine)
        }
        let drawLine = drawManager.curves.lastObject as! DrawLine
        
        let point = gestureRecognizer.location(in: self)
        drawLine.lineArray.add(point)
        
        setNeedsDisplay()
    }
    
    func changeCurvesPoint() {
        for drawLine in drawManager.curves {
            guard let line = drawLine as? DrawLine else {
                continue
            }
            let curve = line.lineArray
            for i in 0 ..< curve.count {
                let point = curve.object(at: i) as! CGPoint
                let kXSize = self.frame.size.width / lastFrame.size.width
                let kYSize = self.frame.size.height / lastFrame.size.height
                let px = point.x * kXSize
                let py = point.y * kYSize
                curve.replaceObject(at: i, with: CGPoint.init(x: px, y: py))
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let cref = UIGraphicsGetCurrentContext()
        
        if firstDrawing {
            cref?.addRect(CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            cref?.setFillColor(red: 0, green: 0, blue: 0, alpha: 0)
            cref?.fillPath()
            firstDrawing = false
        }
        
        for drawLine in drawManager.curves {
            if let line = drawLine as? DrawLine {
                let lineWidth = line.width
                cref?.setLineWidth(lineWidth)
                let curve = line.lineArray
                
                if curve.count >= 2 {
                    guard var point = curve.object(at: 0) as? CGPoint else {
                        return
                    }
                    cref?.beginPath()
                    cref?.move(to: CGPoint(x: point.x, y: point.y))
                    var tmpPoint = point
                    
                    if line.type == .eraser {
                        cref?.setLineCap(CGLineCap.round)
                        cref?.setBlendMode(CGBlendMode.clear)
                        cref?.setLineWidth(line.width)
                    } else {
                        cref?.setBlendMode(CGBlendMode.normal)
                        cref?.setLineWidth(line.width)
                        cref?.setStrokeColor(line.color.cgColor)
                    }
                    
                    for i in 0 ..< curve.count {
                        guard let p = curve.object(at: i) as? CGPoint else {
                            continue
                        }
                        point = p
                        cref?.addQuadCurve(to: CGPoint(x: tmpPoint.x, y: tmpPoint.y), control: CGPoint(x: (tmpPoint.x + point.x)/2, y: (tmpPoint.y + point.y)/2))
                        tmpPoint=point
                    }
                    cref?.strokePath()
                }
            }
        }
    }

}
