//
//  User.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/17.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation

enum UserLevelType {
    case root
    case registed
    case unregisted
    var description: String {
        switch self {
        case .root:
            return "root"
        case .registed:
            return "registed"
        case .unregisted:
            return "unregisted"
        }
    }
}
class User: NSObject {
    // MARK: Properties
    
    var name: String!
    var id: Int!
    var level: UserLevelType!
    var date: String?
    var email: String?
    var age: Int?
    var info: String?
    var comments: String?
    override var description: String {
        var desc = "User { id: " + String(id) + ", name: " + String(name) + ", level: " + level.description
        if let date = self.date {
            desc += ", registerdate: " + date
        }
        if let email = self.email {
            desc += ", email: " + email
        }
        if let age = self.age {
            desc += ", age: " + String(describing: age)
        }
        if let info = self.info {
            desc += ", info: " + info
        }
        if let comments = self.comments {
            desc += ", comments: " + comments
        }
        desc += " }"
        return desc
    }
    
    // MARK: Initialization
    
    init(id: Int, name: String) {
        self.name = name
        self.id = id
        self.level = .unregisted
    }
    
    init(data: Dictionary<String, Any>) {
        id = data["UserID"] as! Int
        name = data["UserName"] as! String
        info = data["UserInfo"] as? String
        date = data["RegisterDate"] as? String
    }
    
    // MARK: Method
    
    func dataFrom(dictionary: Dictionary<String, Any>) {
        id = dictionary["UserID"] as! Int
        name = dictionary["UserName"] as! String
        info = dictionary["UserInfo"] as? String
        date = dictionary["RegisterDate"] as? String
    }
}
