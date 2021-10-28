//
//  Constants.swift
//  Reminders
//
//  Created by namgi on 2021/09/20.
//

import UIKit


// MARK: - Notifications
let userDidEditDataNotificationName: Notification.Name = Notification.Name("userDidEditDataNotificationName")
let userInfoKeyDidEditDataNotification: String = "dataName" // todo, list, ...
let userInfoKeyDidEditDataNotificationValue: String = "editedData"

let userDidSetTodoSettingNotificationName: Notification.Name = Notification.Name("userDidSetTodoSettingNotificationName")
let userInfoKeyDidSetTodoSettingNotification: String = "settingName" // priority, list, ...
let userInfoKeyDidSetTodoSettingNotificationValue: String = "settingValue" // values

// MARK: - ViewControllers
func popModalListViewController(_ viewController: UIViewController, editList list: List) {
    guard let listViewController: ListViewController = viewController.storyboard?.instantiateViewController(withIdentifier: ListViewController.storyboardID) as? ListViewController else { return }
    
    listViewController.list = list
    listViewController.showTitle = "이름 및 모양"
    
    viewController.present(listViewController, animated: true, completion: nil)
}

//func popModalTodoInTableViewController(_ viewController: UIViewController, list: List) {
//    guard let todoViewController: TodoInTableViewController = viewController.storyboard?.instantiateViewController(identifier: TodoInTableViewController.storyboardID) as? TodoInTableViewController
//    else { return }
//    
//    let todo: Todo = Todo(id: String(Date().timeIntervalSince1970),
//                          title: "새로운 미리 알림",
//                          listID: list.id)
//    
//    todoViewController.list = list
//    todoViewController.todo = todo
//    
//    viewController.present(todoViewController, animated: true, completion: nil)
//    
//}

// MARK: - Alerts
func getlistDeleteAlert(list: List, completion: @escaping () -> Void) -> UIAlertController {
    let title: String = "'\(list.title)'을(를) 삭제하시겠습니까?"
    let message: String = "이 목록의 모든 미리 알림이 삭제됩니다."
    
    let alert: UIAlertController = UIAlertController(title: title,
                                                     message: message,
                                                     preferredStyle: UIAlertController.Style.alert)
    
    let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel) { (UIAlertAction) in
        // no action
    }
    
    let deleteAction: UIAlertAction = UIAlertAction(title: "삭제",
                                              style: UIAlertAction.Style.destructive) { (UIAlertAction) in
        completion()
    }
    
    alert.addAction(cancelAction)
    alert.addAction(deleteAction)
    
    return alert
}

func popInformMsgAlert(title: String, message: String,
                       completion: @escaping (_ alert: UIAlertController) -> Void,
                       dismiss: @escaping () -> Void) {
    
    let alert: UIAlertController = UIAlertController(title: title,
                                                     message: message,
                                                     preferredStyle: .alert)
    
    let confirmAction: UIAlertAction = UIAlertAction(title: "확인", style: .default) { (UIAlertAction) in
        dismiss()
    }
    
    alert.addAction(confirmAction)
    
    completion(alert)
}

func popErrorMsgAlert(_ message: String, completion: @escaping (_ alert: UIAlertController) -> Void ) {
    let title: String = "실행 오류"
    
    let alert: UIAlertController = UIAlertController(title: title,
                                                     message: message,
                                                     preferredStyle: .alert)
    
    let confirmAction: UIAlertAction = UIAlertAction(title: "확인", style: .default)
    
    alert.addAction(confirmAction)
    
    completion(alert)
}

func popDiscardChangesAlert(discard: @escaping () -> Void,
                         completion: @escaping (_ alert: UIAlertController) -> Void) {
    let alert: UIAlertController = UIAlertController(title: nil,
                                                     message: nil,
                                                     preferredStyle: .actionSheet)
    
    let discardAction: UIAlertAction = UIAlertAction(title: "변경사항 폐기",
                                                     style: .destructive) { (UIAlertAction) in
        discard()
    }
    
    let cancelAction: UIAlertAction = UIAlertAction(title: "취소",
                                                    style: .cancel,
                                                    handler: nil)
    
    alert.addAction(discardAction)
    alert.addAction(cancelAction)
    
    completion(alert)
}

// MARK: - Properties
let colors: [Int : UIColor] = [
    1 : .systemRed,
    2 : .systemOrange,
    3 : .systemYellow,
    4 : .systemGreen,
    5 : .systemTeal,
    6 : .systemBlue,
    7 : .systemPurple,
    8 : .cyan,
    9 : .systemPink,
    10 : .brown,
    11 : .darkGray,
    12 : .gray
]

typealias ListTuple = (name: String, id: String, title: String, isShow: Bool)
let listTuples: [ListTuple] = [
    ("allListTuple", "001", "전체", false),
    ("flagListTuple", "002", "깃발", false),
    ("basicListTuple", "003", "미리 알림", true)
]
