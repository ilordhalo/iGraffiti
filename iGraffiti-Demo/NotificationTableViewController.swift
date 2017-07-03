//
//  NotificationTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/17.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

class NotificationTableViewController: UITableViewController {
    // MARK: Properties
    
    var userNotiList: NSMutableArray = NSMutableArray()
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: UIViewController Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "WallTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WallTableViewCell
        if cell == nil {
            cell = WallTableViewCell.init()
        }
        cell!.wall = userNotiList.object(at: indexPath.row) as! Wall
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNotiList.count
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.destructive, title: "删除", handler: {_,_ in
            self.userNotiList.removeObject(at: indexPath.row)
            self.tableView.reloadData()
        })
        return [deleteRowAction]
    }
}
