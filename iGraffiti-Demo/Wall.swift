//
//  Wall.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/17.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

enum WallType {
    case personal
    case show
    case graffiti
    var description: String {
        switch self {
        case .personal:
            return "私人墙"
        case .show:
            return "告示墙"
        case .graffiti:
            return "公众墙"
        }
    }
}
class Wall: NSObject {
    // MARK: Properties
    
    var id: Int!
    var name: String!
    var type: WallType!
    var info: String?
    var comments: String?
    var image: UIImage?
    var password: String?
    var userID: Int?
    override var description: String {
        var desc = "Wall { id: " + String(id) + ", name: " + String(name) + ", type: " + type.description
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
    
    override init() {
        super.init()
        self.id = 1
        self.name = ""
        self.type = .graffiti
    }
    
    init(id: Int, name: String, type: WallType) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    // MARK: Method
    
    func dataFrom(dictionary: Dictionary<String, Any>) {
        id = dictionary["WallID"] as! Int
        name = dictionary["WallName"] as! String
        switch dictionary["WallType"] as! String {
        case "show":
            type = .show
        case "personal":
            type = .personal
        case "public":
            type = .graffiti
        default:
            type = .graffiti
        }
        info = dictionary["WallInfo"] as? String
        comments = dictionary["Comments"] as? String
        password = dictionary["WallPassword"] as? String
        userID = dictionary["UserID"] as? Int
    }
    
    override func copy() -> Any {
        let newWall = Wall.init(id: id, name: name, type: type)
        newWall.image = image
        newWall.info = info
        newWall.comments = comments
        newWall.password = password
        return newWall
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Wall else {
            return false
        }
        if object.id == id {
            return true
        }
        return false
    }
}
