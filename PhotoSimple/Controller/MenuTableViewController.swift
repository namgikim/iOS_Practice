//
//  MenuTableViewController.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/12.
//

import UIKit
import PhotosUI

class MenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title: String
        
        if section == 0 {
            title = "사진 기능"
        } else {
            title = "기타 기능"
        }
        return title
    }
}
