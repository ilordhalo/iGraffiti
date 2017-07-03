//
//  SearchTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/9.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SearchTablewViewController: UITableViewController, UITextFieldDelegate {
    // MARK: Preperties
    var searchList: NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let sessionManager : SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
    }
    
    // MARK: UIViewController Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        activityIndicator.startAnimating()
        
        searchList.removeAllObjects()
        if searchField.text == "" {
            
        }
        guard let name = searchField.text else {
            return true
        }
        let parameters: Parameters = [
            "name": name,
            "opw": OP_PASSWORD
        ]
        sessionManager.request(urlCollection["searchwall"]!, parameters: parameters).responseJSON { response in
            self.activityIndicator.stopAnimating()
            guard response.result.isSuccess else {
                return
            }
            guard let value = response.result.value as? Dictionary<String, Any> else {
                return
            }
            let data = value["data"] as! NSArray
            for dic in data {
                let wall = Wall.init()
                wall.dataFrom(dictionary: dic as! Dictionary)
                self.searchList.add(wall)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        return true
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cellIdentifier = "WallTableViewCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WallTableViewCell
            if cell == nil {
                cell = WallTableViewCell.init()
            }
            cell!.wall = searchList.object(at: indexPath.row) as! Wall
            return cell!
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return searchList.count
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath.init(row: 0, section: 1))
        }
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 44
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! WallTableViewCell
            WallManager.sharedInstance.wall = cell.wall
            self.navigationController?.popViewController(animated: true)
            return
        }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! WallTableViewCell
            cell.pushDetailView(pusher: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && searchList.count > 0 {
            return "搜索结果"
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
}
