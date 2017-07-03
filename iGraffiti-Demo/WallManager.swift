//
//  WallManager.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/29.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import Alamofire
import GameplayKit

protocol WallManagerStateDelegate: class {
    func enterWorkState()
    func enterWaitState()
    func enterErrorState()
}

enum WallManagerState {
    case work
    case wait
    case error
}

final class WallManager: WallManagerStateDelegate {
    static let sharedInstance = WallManager()
    
    // MARK: Properties
    
    var lastWalls: NSMutableArray = NSMutableArray()
    var wall: Wall?
    var error: ManagerErrorType = .no
    lazy var stateMachine: GKStateMachine = {
        var state = [
            WallManagerWorkState(delegate: self),
            WallManagerWaitState(delegate: self),
            WallManagerErrorState(delegate: self)
        ]
        return GKStateMachine(states: state)
    }()
    let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    // MARK: Initialization
    
    private init() {
    }
    
    // MARK: Network Model
    
    func uploadDrawing(image: UIImage) {
        guard let wall = wall else {
            stateMachine.enter(WallManagerErrorState.self)
            error = .type
            return
        }
        guard stateMachine.canEnterState(WallManagerWorkState.self) else {
            stateMachine.enter(WallManagerErrorState.self)
            error = .state
            return
        }
        stateMachine.enter(WallManagerWorkState.self)
        let imageData = UIImagePNGRepresentation(image)
        let target = String(wall.id)
        let url = urlCollection["paste"]!
        sessionManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(target.data(using: String.Encoding.utf8)!, withName: "target")
                multipartFormData.append(imageData!, withName: "pic", fileName: "myImage.png", mimeType: "image/png")
        },
            to: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        debugPrint(response)
                    }
                    self.stateMachine.enter(WallManagerWaitState.self)
                case .failure(let encodingError):
                    print(encodingError)
                    self.stateMachine.enter(WallManagerErrorState.self)
                    self.error = .network
                }
        }
        )
    }
    
    func refresh() {
        guard let wall = wall else {
            stateMachine.enter(WallManagerErrorState.self)
            error = .type
            return
        }
        requestWallData(target: wall.id)
    }
    
    func requestRandomWall() {
        requestWallData(target: 0)
    }
    
    func requestWallData(target: Int) {
        guard stateMachine.canEnterState(WallManagerWorkState.self) else {
            stateMachine.enter(WallManagerErrorState.self)
            error = .state
            return
        }
        stateMachine.enter(WallManagerWorkState.self)
        
        let parameters: Parameters = [
            "target": String(target),
            "password": OP_PASSWORD
        ]
        
        sessionManager.request(urlCollection["walldata"]!, parameters: parameters).responseJSON { response in
            guard response.result.isSuccess else {
                self.stateMachine.enter(WallManagerErrorState.self)
                self.error = .network
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                self.stateMachine.enter(WallManagerErrorState.self)
                self.error = .type
                return
            }
            let data = value["data"] as! Dictionary<String, Any>
            self.wall?.dataFrom(dictionary: data)
            let url = urlCollection["wall"]! + String(self.wall!.id) + ".jpg"
            self.sessionManager.request(url, method:.get).response { response in
                guard let data = response.data else {
                    self.stateMachine.enter(WallManagerErrorState.self)
                    self.error = .type
                    return
                }
                let image = UIImage(data: data)
                self.wall?.image = image
                self.stateMachine.enter(WallManagerWaitState.self)
            }
        }
    }
    
    func addNotification() {
        guard let _ = UserManager.sharedInstance.user else {
            return
        }
        guard stateMachine.canEnterState(WallManagerWorkState.self) else {
            stateMachine.enter(WallManagerErrorState.self)
            error = .state
            return
        }
        stateMachine.enter(WallManagerWorkState.self)
    }
    
    // MARK: Manage Method
    
    func getLastWall() {
        guard let lastWall = lastWalls.lastObject as? Wall else {
            return
        }
        wall = lastWall.copy() as? Wall
        lastWalls.removeLastObject()
    }
    
    func getNextWall() {
        lastWalls.add(wall!.copy())
        wall?.id = 0
    }
        
    // MARK: WallManagerStateDelegate
    
    func enterWaitState() {
        
    }
    func enterWorkState() {
        
    }
    func enterErrorState() {
        
    }
    
    
}
