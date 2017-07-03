//
//  GKStateMachine+State.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/22.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit
import GameplayKit

extension GKStateMachine {
    var stateType: AnyObject? {
        guard let stateType = self.currentState?.classForCoder else {
            return nil
        }
        switch stateType {
        case _ as WallViewControllerDrawState.Type:
            return WallViewControllerState.draw as AnyObject
        case _ as WallViewControllerWorkState.Type:
            return WallViewControllerState.work as AnyObject
        case _ as WallViewControllerWaitState.Type:
            return WallViewControllerState.wait as AnyObject
        case _ as WallManagerWorkState.Type:
            return WallManagerState.work as AnyObject
        case _ as WallManagerWaitState.Type:
            return WallManagerState.wait as AnyObject
        case _ as WallManagerErrorState.Type:
            return WallManagerState.error as AnyObject
        default:
            return nil
        }
    }
}
