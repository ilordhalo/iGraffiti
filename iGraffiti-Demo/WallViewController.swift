//
//  WallViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/4/19.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit
import Alamofire
import GameplayKit

protocol WallViewControllerStateDelegate: class {
    func enterDrawState()
    func enterWorkState()
    func enterWaitState()
}

enum StateType {
    case work
    case wait
}

enum WallViewControllerState {
    case draw
    case work
    case wait
}

class WallViewController: UIViewController, WallViewControllerStateDelegate {
    // MARK: Properties
    
    @IBOutlet weak var wallImageView: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var drawTableView: DrawTableView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var workView: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var favoButton: UIButton!
    @IBOutlet weak var notiButton: UIButton!
    @IBOutlet weak var penButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    
    let wallManager: WallManager = WallManager.sharedInstance
    let userManager: UserManager = UserManager.sharedInstance
    var showFrame: CGRect!
    lazy var stateMachine: GKStateMachine = {
        var state = [
            WallViewControllerWaitState(delegate: self),
            WallViewControllerDrawState(delegate: self),
            WallViewControllerWorkState(delegate: self)
        ]
        return GKStateMachine(states: state)
    }()
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showFrame = drawTableView.frame
        addGestureRecognizerToView(wallImageView)

        wallManager.wall = Wall.init(id: 1, name: "", type: .graffiti)
        stateMachine.enter(WallViewControllerWaitState.self)
    }
    
    // MARK: ViewController Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        refreshData()
        
        userManager.refreshFavoList()
        userManager.refreshNotiList()
    }
    
    // MARK: IBAction
    
    @IBAction func penButtonTouchUpInside(_ sender: UIButton) {
        drawTableView.drawManager.usePen(width: 1, color: UIColor.black)
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                sender.isHighlighted = true
                self.eraserButton.isHighlighted = false
            }
        }
    }
    
    @IBAction func eraserButtonTouchUpInside(_ sender: UIButton) {
        drawTableView.drawManager.useEraser(width: 5)
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                sender.isHighlighted = true
                self.penButton.isHighlighted = false
            }
        }
    }
    
    @IBAction func undoButtonTouchUpInside(_ sender: UIButton) {
        drawTableView.undoDraw()
    }
    
    @IBAction func redoButtonTouchUpInside(_ sender: UIButton) {
        drawTableView.redoDraw()
    }
    
    @IBAction func addButtonTouch(_ sender: UIBarButtonItem) {
        if wallManager.wall?.type == .show && !userManager.wallList.contains(wallManager.wall!) {
            AlertMessage(message: "告示墙只允许创建者添加涂鸦", viewController: self)
            return
        }
        if wallImageView.image == nil {
            return
        }
        drawTableView.drawManager.usePen(width: 1, color: UIColor.black)
        penButton.isHighlighted = true
        eraserButton.isHighlighted = false
        stateMachine.enter(WallViewControllerDrawState.self)
    }
    
    @IBAction func closeButtonTouchUpInside(_ sender: UIButton) {
        stateMachine.enter(WallViewControllerWaitState.self)
        drawTableView.resetDrawing()
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: UIButton) {
        guard let image = wallImageView.image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        
    }
    
    @IBAction func refreshButtonTouchUpInside(_ sender: UIBarButtonItem) {
        refreshData()
        drawTableView.resetDrawing()
    }
    
    @IBAction func infoButtonTouchUpInside(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WallInfoTableViewController") as! WallInfoTableViewController
        viewController.wall = wallManager.wall
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)

    }
    
    @IBAction func uploadButtonTouchUpInside(_ sender: UIButton) {
        let oldSize = wallImageView.frame.size
        guard let size = wallImageView.image?.size else {
            return
        }
        wallImageView.frame.size = size
        drawTableView.frame.size = size
        guard let image = drawTableView.currentImage() else {
            return
        }
        wallImageView.frame.size = oldSize
        drawTableView.frame.size = oldSize
        stateMachine.enter(WallViewControllerWorkState.self)
        wallManager.uploadDrawing(image: image)
        DispatchQueue.global(qos: .userInitiated).async {
            while self.wallManager.stateMachine.stateType as! WallManagerState == .work {
            }
            DispatchQueue.main.async {
                self.stateMachine.enter(WallViewControllerWaitState.self)
                self.drawTableView.resetDrawing()
                if self.wallManager.stateMachine.stateType as! WallManagerState == .error {
                    print(self.wallManager.error.info)
                    self.wallManager.stateMachine.enter(WallManagerWaitState.self)
                }
            }
        }
    }
    
    @IBAction func favoButtonTouchUpInside(_ sender: UIButton) {
        guard let _ = userManager.user else {
            AlertMessage(message: "请先登录", viewController: self)
            return
        }
        if sender.isSelected == true {
            stateMachine.enter(WallViewControllerWorkState.self)
            userManager.removeFavo(block: { message in
                if message == .success {
                    self.favoButton.isSelected = false
                    self.favoButton.isHighlighted = false
                }
                self.stateMachine.enter(WallViewControllerWaitState.self)
            })
        }
        else {
            stateMachine.enter(WallViewControllerWorkState.self)
            userManager.addFavo(block: { message in
                if message == .success {
                    self.favoButton.isSelected = true
                    self.favoButton.isHighlighted = true
                }
                self.stateMachine.enter(WallViewControllerWaitState.self)
            })
        }
    }
    
    @IBAction func notiButtonTouchUpInside(_ sender: UIButton) {
        guard let _ = userManager.user else {
            AlertMessage(message: "请先登录", viewController: self)
            return
        }
        if sender.isSelected == true {
            stateMachine.enter(WallViewControllerWorkState.self)
            userManager.removeNoti(block: { message in
                if message == .success {
                    self.notiButton.isSelected = false
                    self.notiButton.isHighlighted = false
                }
                self.stateMachine.enter(WallViewControllerWaitState.self)
            })
        }
        else {
            stateMachine.enter(WallViewControllerWorkState.self)
            userManager.addNoti(block: { message in
                if message == .success {
                    self.notiButton.isSelected = true
                    self.notiButton.isHighlighted = true
                }
                self.stateMachine.enter(WallViewControllerWaitState.self)
            })
        }
    }
    
    // MARK: UIGestureRecognizer
    
    func addGestureRecognizerToView(_ view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panMethod(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        /*
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panView(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchView(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        */
    }
    
    func pinchView(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        let view = pinchGestureRecognizer.view! as! UIImageView
        let backView = drawTableView!
        if pinchGestureRecognizer.state == UIGestureRecognizerState.began || pinchGestureRecognizer.state == UIGestureRecognizerState.changed {
            view.transform = view.transform.scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
            if view.frame.size < showFrame.size {
                view.frame = showFrame
            }
            backView.frame.size = view.frame.size
            pinchGestureRecognizer.scale = 1
        }
    }
    
    func panView(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let view = panGestureRecognizer.view!
        let backView = drawTableView!
        if panGestureRecognizer.state == UIGestureRecognizerState.began || panGestureRecognizer.state == UIGestureRecognizerState.changed {
            let translation = panGestureRecognizer.translation(in: view.superview)
            view.center = CGPoint.init(x: view.center.x + translation.x, y: view.center.y + translation.y)
            //backView.center = CGPoint.init(x: view.center.x + translation.x, y: view.center.y + translation.y)
            backView.frame = view.frame
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        }
    }
    
    func panMethod(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let view = panGestureRecognizer.view!
        if stateMachine.stateType as! WallViewControllerState == .work {
            return
        }
        if panGestureRecognizer.state == UIGestureRecognizerState.began || panGestureRecognizer.state == UIGestureRecognizerState.changed {
            let translation = panGestureRecognizer.translation(in: view.superview)
            let location = panGestureRecognizer.location(ofTouch: 0, in: view)
            if translation.x > 20 && location.x < 0.25*view.frame.size.width {
                showLastView()
            }
            else if translation.x < 20 && location.x > 0.75*view.frame.size.width {
                showNextView()
            }
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        }
    }

    // MARK: WallViewControllerDelegate
    
    func enterDrawState() {
        mainView.sendSubview(toBack: wallImageView)
        toolView.isHidden = false
        menuView.isHidden = true
        addButton.isEnabled = false
        searchButton.isEnabled = false
    }
    
    func enterWaitState() {
        mainView.sendSubview(toBack: drawTableView)
        toolView.isHidden = true
        menuView.isHidden = false
        addButton.isEnabled = true
        searchButton.isEnabled = true
        workView.isHidden = true
    }
    
    func enterWorkState() {
        workView.isHidden = false
    }
    
    // MARK: Method
    
    func startTrasition() {
        let transition = CATransition.init()
        transition.repeatCount = 1
        transition.type = "rippleEffect"
        transition.subtype = kCATransitionFromLeft
        wallImageView.layer.add(transition, forKey: nil)
    }
    
    func showLastView() {
        startTrasition()
        wallManager.getLastWall()
        refreshData()
    }
    
    func showNextView() {
        startTrasition()
        wallManager.getNextWall()
        refreshData()
    }
    
    func refreshData() {
        stateMachine.enter(WallViewControllerWorkState.self)
        wallManager.refresh()
        DispatchQueue.global(qos: .userInitiated).async {
            while self.wallManager.stateMachine.stateType as! WallManagerState == .work {
            }
            DispatchQueue.main.async {
                self.stateMachine.enter(WallViewControllerWaitState.self)
                if self.wallManager.stateMachine.stateType as! WallManagerState == .error {
                    print(self.wallManager.error.info)
                    self.wallManager.stateMachine.enter(WallManagerWaitState.self)
                }
                self.refreshWall()
            }
        }
    }
    
    func refreshWall() {
        self.navigationItem.title = wallManager.wall?.name
        self.wallImageView.image = nil
        if wallManager.wall?.type == .personal && !userManager.acceptList.contains(wallManager.wall!) {
            let alert = UIAlertController.init(title: "请输入密码", message: "私人墙需要密码来访问", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "密码"
                textField.isSecureTextEntry = true
            })
            let action = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default, handler: { alertAction in
                let pw = alert.textFields!.first!.text
                if md5String(str: pw!) == self.wallManager.wall?.password {
                    self.userManager.acceptList.add(self.wallManager.wall!.copy())
                    self.wallImageView.image = self.wallManager.wall?.image
                    if self.userManager.favoList.contains(self.wallManager.wall!) {
                        self.favoButton.isSelected = true
                        self.favoButton.isHighlighted = true
                    }
                    else {
                        self.favoButton.isSelected = false
                        self.favoButton.isHighlighted = false
                    }
                    if self.userManager.notiList.contains(self.wallManager.wall!) {
                        self.notiButton.isSelected = true
                        self.notiButton.isHighlighted = true
                    }
                    else {
                        self.notiButton.isSelected = false
                        self.notiButton.isHighlighted = false
                    }
                }
                else {
                    AlertMessage(message: "密码错误", viewController: self)
                }
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            wallImageView.image = wallManager.wall?.image
            if userManager.favoList.contains(wallManager.wall!) {
                favoButton.isSelected = true
                favoButton.isHighlighted = true
            }
            else {
                favoButton.isSelected = false
                favoButton.isHighlighted = false
            }
            if userManager.notiList.contains(wallManager.wall!) {
                notiButton.isSelected = true
                notiButton.isHighlighted = true
            }
            else {
                notiButton.isSelected = false
                notiButton.isHighlighted = false
            }
        }

        /*
        wallImageView.layer.masksToBounds = true
        wallImageView.frame.size = wallImageView.image!.size
        drawTableView.frame = wallImageView.frame*/
    }
    
}
