//
//  TodoInfoSettingTableViewController.swift
//  Reminders
//
//  Created by namgi on 2021/09/30.
//

import UIKit

class TodoInfoSettingTableViewController: UITableViewController {

    // MARK: - Properties
    var prioritys: [Priority] = [.none, .low, .middle, .high]
    var lists: [List] = List.allListWithSort()
    var targetSetting: Setting? // 설정할 값에 따른 정보를 테이블에 나열한다.
    
    var todo: Todo?
    
    // MARK: - enums
    enum Setting: Int {
        case priority = 101
        case list
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.targetSetting == .priority { return self.prioritys.count }
        else if self.targetSetting == .list { return self.lists.count }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        
        // 메뉴 - 우선순위 설정
        if self.targetSetting == .priority {
            guard prioritys.count > indexPath.row else { return cell }
            
            guard let priority: Priority = self.todo?.priority else { return cell}
            
            cell.textLabel?.text = Priority.priorityName(self.prioritys[indexPath.row])
            
            if priority == self.prioritys[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
        // 메뉴 - 목록 설정
        } else if self.targetSetting == .list {
            guard lists.count > indexPath.row else { return cell }
            
            guard let todo: Todo = self.todo else { return cell }
            
            cell.textLabel?.text = self.lists[indexPath.row].title
            cell.imageView?.image = UIImage(systemName: "line.horizontal.3.circle.fill")
            
            if let color: Int = self.lists[indexPath.row].color {
                cell.imageView?.tintColor = colors[color]
            } else {
                cell.imageView?.tintColor = colors[6]
            }
            
            if todo.listID == self.lists[indexPath.row].id {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for cell in self.tableView.visibleCells {
            if cell.isSelected {
                cell.accessoryType = .checkmark
                
                var userInfo: [String : Any]?
                if self.targetSetting == .priority { // 우선 순위
                    userInfo = [userInfoKeyDidSetTodoSettingNotification : "priority",
                                userInfoKeyDidSetTodoSettingNotificationValue : self.prioritys[indexPath.row]]
                    
                } else if self.targetSetting == .list { // 목록
                    userInfo = [userInfoKeyDidSetTodoSettingNotification : "list",
                                userInfoKeyDidSetTodoSettingNotificationValue : self.lists[indexPath.row]]
                }
                
                if userInfo != nil {
                    NotificationCenter.default.post(name: userDidSetTodoSettingNotificationName,
                                                    object: nil,
                                                    userInfo: userInfo)
                }
                
            } else { cell.accessoryType = .none }
        }
        
        // 셀 선택 해제
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
