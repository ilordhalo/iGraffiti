//
//  MD5.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/15.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation

func md5String(str:String) -> String{
    let cStr = str.cString(using: String.Encoding.utf8);
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
    CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
    let md5String = NSMutableString();
    for i in 0 ..< 16{
        md5String.appendFormat("%02x", buffer[i])
    }
    free(buffer)
    return md5String as String
}
