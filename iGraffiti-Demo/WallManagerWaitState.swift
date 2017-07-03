//
//  WallManagerWaitState.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/29.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit
import GameplayKit

class WallManagerWaitState: GKState {
    // MARK: Properties
    
    unowned var delegate: WallManagerStateDelegate
    
    // MARK: Initialization
    
    init(delegate: WallManagerStateDelegate) {
        self.delegate = delegate
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        delegate.enterWaitState()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass is WallManagerWorkState.Type) || (stateClass is WallManagerErrorState.Type)
    }
}
