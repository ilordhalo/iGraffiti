//
//  ManagerErrorType.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/29.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation

enum ManagerErrorType {
    case network
    case state
    case type
    case no
    var info: String {
        switch self {
        case .network:
            return "Network Error"
        case .state:
            return "State Error"
        case .type:
            return "DataType Error"
        case .no:
            return "No Error"
        }
    }
}
