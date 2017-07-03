//
//  NotiWallListTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/17.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

class NotiWallListTableViewController: UITableViewController {
    // MARK: Properties
    
    let userManager = UserManager.sharedInstance
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: UIViewController Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        userManager.refreshNotiList(block: { message in
            if message == .success {
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userManager.notiList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "WallTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WallTableViewCell
        if cell == nil {
            cell = WallTableViewCell.init()
        }
        cell!.wall = userManager.notiList.object(at: indexPath.row) as! Wall
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! WallTableViewCell
        cell.pushWallView()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WallTableViewCell
        cell.pushDetailView(pusher: self)
    }
}
