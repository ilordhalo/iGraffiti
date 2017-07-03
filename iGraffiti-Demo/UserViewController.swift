//
//  UserViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/5.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Types
    
    enum SegmentedControlType {
        case favo
        case my
    }
    
    // MARK: Properties
    
    let userManager: UserManager = UserManager.sharedInstance
    
    @IBOutlet weak var logButton: UIBarButtonItem!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var createWallButton: UIButton!
    
    var selectedInfo: SegmentedControlType = .favo
    
    // MARK: Initializatioin
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextView.frame = infoLabel.frame
        infoTextView.layoutManager.allowsNonContiguousLayout = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: UIViewController Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userManager.user != nil {
            logButton.image = UIImage.init(named: "logout")
        }
        else {
            logButton.image = UIImage.init(named: "login")
        }
        if selectedInfo == .favo {
            createWallButton.isHidden = true
        }
        else {
            createWallButton.isHidden = false
        }
        editButton.setTitle("编辑", for: UIControlState.normal)
        refreshData()
    }
    
    // MARK: IBAction
    
    @IBAction func createWallButtonTouchUpInside(_ sender: UIButton) {
        guard let _ = userManager.user else {
            AlertMessage(message: "登录后才可以创建", viewController: self)
            return
        }
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CreateWallTableViewController")
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func editButtonTouchUpInside(_ sender: UIButton) {
        guard let _ = userManager.user else {
            AlertMessage(message: "请先登录", viewController: self)
            return
        }
        if editButton.titleLabel?.text == "编辑" {
            infoTextView.text = infoLabel.text
            view.bringSubview(toFront: infoTextView)
            editButton.setTitle("确定", for: UIControlState.normal)
        }
        else {
            infoTextView.resignFirstResponder()
            view.sendSubview(toBack: infoTextView)
            editButton.setTitle("编辑", for: UIControlState.normal)
            infoLabel.text = infoTextView.text
            userManager.uploadUserInfo(info: infoLabel.text!)
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedInfo = .favo
            createWallButton.isHidden = true
        }
        else {
            selectedInfo = .my
            createWallButton.isHidden = false
        }
        tableView.reloadData()
    }
    
    @IBAction func logButtonTouchUpInside(_ sender: UIBarButtonItem) {
        if sender.image == UIImage.init(named: "logout") {
            userManager.logout()
            AlertMessage(message: "已登出", viewController: self)
            sender.image = UIImage.init(named: "login")
            tableView.reloadData()
            infoLabel.text = ""
            self.navigationItem.title = ""
        }
        else {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignTableViewController")
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "WallTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WallTableViewCell
        if cell == nil {
            cell = WallTableViewCell.init()
        }
        if selectedInfo == .favo {
            cell!.wall = userManager.favoList.object(at: indexPath.row) as! Wall
        }
        else {
            cell!.wall = userManager.wallList.object(at: indexPath.row) as! Wall
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! WallTableViewCell
        cell.pushWallView()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WallTableViewCell
        cell.pushDetailView(pusher: self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedInfo == .favo {
            return userManager.favoList.count
        }
        else {
            return userManager.wallList.count
        }
    }
    
    // MARK: Method
    
    func refreshData() {
        userManager.refreshUserData(block: { message in
            switch message {
            case .error:
                AlertMessage(message: "网络错误", viewController: self)
            case .success:
                self.navigationItem.title = self.userManager.user?.name
                self.infoLabel.text = self.userManager.user?.info
            default: break
            }
        })
        self.tableView.reloadData()
        userManager.refreshFavoList(block: { message in
            if message == .success {
                self.tableView.reloadData()
            }
        })
        userManager.refreshWallList(block: { message in
            if message == .success {
                self.tableView.reloadData()
            }
        })
    }
    
}
