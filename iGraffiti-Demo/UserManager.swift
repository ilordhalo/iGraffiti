//
//  UserManager.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/17.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import Alamofire

enum UserManagerState {
    case work
    case wait
    case error
}

final class UserManager {
    static let sharedInstance = UserManager()
    
    static var deviceToken = ""
    // MARK: Properties
    
    var user: User?
    var acceptList: NSMutableArray = NSMutableArray()
    var favoList: NSMutableArray = NSMutableArray()
    var notiList: NSMutableArray = NSMutableArray()
    var wallList: NSMutableArray = NSMutableArray()
    
    weak var signUpDelegate: SignUpDelegate?
    weak var signInDelegate: SignInDelegate?
    
    let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    // MARK: Initialization
    
    private init() {
    }
    
    // MARK: Method
    
    func logout() {
        user = nil
        favoList.removeAllObjects()
        wallList.removeAllObjects()
        notiList.removeAllObjects()
        acceptList.removeAllObjects()
    }
    
    // MARK: Network Method
    
    func refreshUserData(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["userinfo"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            let data = value["data"] as! Dictionary<String, Any>
            self.user?.dataFrom(dictionary: data)
            DispatchQueue.main.async {
                block?(.success)
            }
        }
    }
    
    func signUp(userName: String, password: String, info: String) {
        let parameters: Parameters = [
            "un": userName,
            "pw": password,
            "info": info,
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["createuser"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                self.signUpDelegate?.response = "error"
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            let data = value["ans"] as! String
            self.signUpDelegate?.response = data
            DispatchQueue.main.async {
                self.signUpDelegate?.signUpFinished()
            }
        }
    }
    
    func signIn(userName: String, password: String) {
        let parameters: Parameters = [
            "un": userName,
            "pw": password,
            "dt": UserManager.deviceToken,
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["login"]!, parameters: parameters).responseJSON { response in
            var message = ""
            guard response.result.isSuccess else {
                message = "error"
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            message = value["ans"] as! String
            if message == "success" {
                let data = value["data"] as! Dictionary<String, Any>
                self.user = User.init(data: data)
            }
            DispatchQueue.main.async {
                self.signInDelegate?.signInFinished(message: message)
            }
        }
    }
    
    func addFavo(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user, let wall = WallManager.sharedInstance.wall else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "wid": String(wall.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["addfavo"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            DispatchQueue.main.async {
                self.refreshFavoList()
                block?(.success)
            }
        }
    }
    
    func removeFavo(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user, let wall = WallManager.sharedInstance.wall else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "wid": String(wall.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["removefavo"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            DispatchQueue.main.async {
                self.refreshFavoList()
                block?(.success)
            }
        }
    }
    
    func refreshFavoList(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["favolist"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            self.favoList.removeAllObjects()
            let data = value["data"] as! NSArray
            for dic in data {
                let wall = Wall.init()
                wall.dataFrom(dictionary: dic as! Dictionary)
                self.favoList.add(wall)
            }
            DispatchQueue.main.async {
                block?(.success)
            }
        }
    }
    
    func refreshWallList(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["walllist"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            self.wallList.removeAllObjects()
            let data = value["data"] as! NSArray
            for dic in data {
                let wall = Wall.init()
                wall.dataFrom(dictionary: dic as! Dictionary)
                self.wallList.add(wall)
            }
            DispatchQueue.main.async {
                block?(.success)
            }
        }
    }
    
    func uploadUserInfo(info: String) {
        guard let user = user else {
            return
        }
        user.info = info
        let parameters: Parameters = [
            "uid": String(user.id),
            "info": info,
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["uui"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                return
            }
        }
    }
    
    func addNoti(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user, let wall = WallManager.sharedInstance.wall else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "wid": String(wall.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["addnoti"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            DispatchQueue.main.async {
                self.refreshNotiList()
                block?(.success)
            }
        }
    }
    
    func removeNoti(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user, let wall = WallManager.sharedInstance.wall else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "wid": String(wall.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["removenoti"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            DispatchQueue.main.async {
                self.refreshNotiList()
                block?(.success)
            }
        }
    }
    
    func refreshNotiList(block: ((RequestMessageType) -> Void)? = nil) {
        guard let user = user else {
            return
        }
        let parameters: Parameters = [
            "uid": String(user.id),
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["notilist"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                DispatchQueue.main.async {
                    block?(.error)
                }
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            self.notiList.removeAllObjects()
            let data = value["data"] as! NSArray
            for dic in data {
                let wall = Wall.init()
                wall.dataFrom(dictionary: dic as! Dictionary)
                self.notiList.add(wall)
            }
            DispatchQueue.main.async {
                block?(.success)
            }
        }
    }
}
