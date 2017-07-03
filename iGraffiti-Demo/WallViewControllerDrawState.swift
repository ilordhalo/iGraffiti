//
//  WallViewControllerDrawState.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/22.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit
import GameplayKit

class WallViewControllerDrawState: GKState {
    // MARK: Properties
    
    unowned var delegate: WallViewControllerStateDelegate

    // MARK: Initialization
    
    init(delegate: WallViewControllerStateDelegate) {
        self.delegate = delegate
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        delegate.enterDrawState()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass is WallViewControllerWaitState.Type) || (stateClass is WallViewControllerWorkState.Type)
    }
}
