//
//  Global.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/30.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation

let OP_PASSWORD = "ilordhalo@me.com"

enum RequestMessageType {
    case error
    case empty
    case success
    case other
    init(message: String) {
        switch message {
        case "error":
            self = .error
        case "empty":
            self = .empty
        case "success":
            self = .success
        default:
            self = .other
        }
    }
}

let urlCollection: Dictionary<String, String> = ["userinfo": "http://ilordhalo.me/iGraffiti/userinfo", "createuser": "http://ilordhalo.me/iGraffiti/createuser", "login": "http://ilordhalo.me/iGraffiti/login", "addfavo": "http://ilordhalo.me/iGraffiti/addfavo", "removefavo": "http://ilordhalo.me/iGraffiti/removefavo", "favolist": "http://ilordhalo.me/iGraffiti/favolist", "walllist": "http://ilordhalo.me/iGraffiti/walllist", "uui": "http://ilordhalo.me/iGraffiti/uui", "addnoti": "http://ilordhalo.me/iGraffiti/addnoti", "removenoti": "http://ilordhalo.me/iGraffiti/removenoti", "notilist": "http://ilordhalo.me/iGraffiti/notilist", "paste": "http://ilordhalo.me/iGraffiti/paste/", "walldata": "http://ilordhalo.me/iGraffiti/walldata", "wall": "http://ilordhalo.me/static/wall", "cratewall": "http://ilordhalo.me/iGraffiti/createwall", "searchwall": "http://ilordhalo.me/iGraffiti/searchwall", "walldata": "http://ilordhalo.me/iGraffiti/walldata"]




