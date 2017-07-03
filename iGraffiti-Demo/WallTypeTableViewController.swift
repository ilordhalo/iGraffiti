//
//  WallTypeTableViewController.swift
//  iGraffiti-Demo
//
//  Created by 张 家豪 on 2017/5/8.
//  Copyright © 2017年 张 家豪. All rights reserved.
//

import Foundation
import UIKit

class WallTypeTableViewController: UITableViewController {
    // MARK: Properties
    
    var typeLabel: UILabel!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        switch indexPath.row {
        case 0:
            typeLabel.text = "公众墙"
        case 1:
            typeLabel.text = "告示墙"
        case 2:
            typeLabel.text = "私人墙"
        default: break
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if typeLabel.text == "公众墙" && indexPath.row == 0 {
            cell.accessoryType = .checkmark
        }
        else if typeLabel.text == "告示墙" && indexPath.row == 1 {
            cell.accessoryType = .checkmark
        }
        else if typeLabel.text == "私人墙" && indexPath.row == 2 {
            cell.accessoryType = .checkmark
        }
        return cell
    }
}
