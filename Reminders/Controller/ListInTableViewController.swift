//
//  ListInTableViewController.swift
//  Reminders
//
//  Created by namgi on 2021/10/07.
//

import UIKit

class ListInTableViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTodoBarButtonIcon: UIBarButtonItem!
    @IBOutlet weak var addTodoBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let numberFomatter: NumberFormatter = {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 첫 화면으로서 필요한 초기휘
        // 전체, 깃발, 미리알림 등 기초 목록을 생성한다.
        self.initialize()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        // Notification Observer 추가
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveUserDidEditDataNotification(_:)),
                                               name: userDidEditDataNotificationName,
                                               object: nil)
        
        // List의 allList 변화를 감지해서, 알림추가버튼의 활성화 여부를 적용함.
        List.delegate = self
        
        self.setAddTodoBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 목록 갱신
        DispatchQueue.main.async {
            self.allReload()
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 알림 목록으로 이동
        if let todosInTableViewController = segue.destination as?  TodosInTableViewController {
            
            if segue.identifier == "showTodoList" {
            
                guard let cell: UITableViewCell = sender as? UITableViewCell else { return }
                guard let index: Int = self.tableView.indexPath(for: cell)?.row else { return }
                
                let list: List = List.allListWithSort()[index]
                
                todosInTableViewController.list = list
                
            } else if segue.identifier == "showFlagList" {
                if let flagListTuple: ListTuple = listTuples.first(where: { (tuple: ListTuple) -> Bool in
                    tuple.name == "flagListTuple"
                }) {
                    todosInTableViewController.list = List.listForID(flagListTuple.id)
                }
            }
            
        // 알림 세부사항으로 이동
        } else if let navigationController: UINavigationController = segue.destination as? UINavigationController {
            
            if let todoInTableViewController: TodoInTableViewController = navigationController.topViewController as? TodoInTableViewController {
                
                let list: List = List.allListWithSort()[0]
                let todo: Todo = Todo(id: String(Date().timeIntervalSince1970),
                                      title: "",
                                      listID: list.id)
            
                todoInTableViewController.list = list
                todoInTableViewController.todo = todo
                todoInTableViewController.successBarButton.isEnabled = false
            }
        }
    }

}

extension ListInTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "나의 목록"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return List.allListWithSort().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)

        guard List.allListWithSort().count > indexPath.row else { return cell }

        let list: List = List.allListWithSort()[indexPath.row]
        
        cell.textLabel?.text = list.title
        cell.detailTextLabel?.text = String(Todo.countTodoOfList(id: list.id, withSuccessTodo: false))
        cell.detailTextLabel?.textColor = .darkGray
        
        if let color: Int = list.color {
            cell.imageView?.tintColor = colors[color]
        } else {
            cell.imageView?.tintColor = colors[6]
        }
        
        return cell
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    */
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let list: List = List.allListWithSort()[indexPath.row]
        
        let infoAction: UIContextualAction
        infoAction = UIContextualAction(style: UIContextualAction.Style.normal,
                                  title: "info",
                                  handler: { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                                    
                                    popModalListViewController(self, editList: list)
                                    
                                    success(true)
                                  })
        infoAction.backgroundColor = .systemGray
        infoAction.image = UIImage(systemName: "info.circle.fill")
        
        let deleteAction: UIContextualAction
        deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive,
                                    title: "delete",
                                    handler: { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                                        
                                        if Todo.countTodoOfList(id: list.id, withSuccessTodo: true) == 0 {
                                            self.removeRow(list, indexPath: indexPath)
                                            
                                        } else {
                                            let alert: UIAlertController = getlistDeleteAlert(list: list) {
                                                self.removeRow(list, indexPath: indexPath)
                                            }
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                        success(true)
                                    })
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let config: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        
        return config
    }
}

extension ListInTableViewController {
    
    // MARK: - Methods
    private func initialize() {
        
        if List.allList.count == 0 {
            List.initializeList()
        }
    }
    
    private func removeRow(_ list: List, indexPath: IndexPath) {
        let isSuccess: Bool = list.remove()
        if isSuccess == false {
            print("목록 삭제 오류가 발생했습니다. 다시 시도해주세요.")
        }
        
        // 목록 갱신
        self.allReload()
    }
    
    /**
     '이름 및 모양' 메뉴로 변경한 내역을 반영한다.
     */
    @objc private func didReceiveUserDidEditDataNotification(_ noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let action: String = userInfo[userInfoKeyDidEditDataNotification] as? String else { return }
        
        if action == "list" || action == "todo" {
            // guard let _: List = userInfo["editedData"] as? List else { return }
            // guard let _: Todo = userInfo["editedData"] as? Todo else { return }
            self.allReload()
        }
    }
    
    
    /// 알림 추가버튼 활성화 여부
    private func setAddTodoBarButton() {
        addTodoBarButton.isEnabled = List.allListWithSort().count == 0 ? false : true
        addTodoBarButtonIcon.isEnabled = List.allListWithSort().count == 0 ? false : true
    }
    
    private func allReload() {
        self.tableView.performBatchUpdates({
            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.automatic)
        }, completion: nil)
        
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
}

extension ListInTableViewController: ListDelegate {
    
    /// List.allList 의 didSet 에 의해 동작하는 메소드.
    func listDidEdit() {
        self.setAddTodoBarButton()
    }
}

extension ListInTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCollectionCell", for: indexPath) as! ListCollectionViewCell
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "전체"
            cell.logoImageView.image = UIImage(systemName: "tray.circle.fill")
            cell.logoImageView.tintColor = .darkGray
            cell.countLabel.text = numberFomatter.string(from: NSNumber(value: Todo.countAllTodo(withSuccessTodo: false)))
            
        } else {
            cell.titleLabel.text = "깃발 표시"
            cell.logoImageView.image = UIImage(systemName: "flag.circle.fill")
            cell.logoImageView.tintColor = .systemOrange
            cell.countLabel.text = numberFomatter.string(from: NSNumber(value: Todo.countTodo(isFlag: true)))
        }
        
        cell.layer.cornerRadius = 10.0
        
        return cell
    }
}

extension ListInTableViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

//        guard let flowLayout: UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//            return CGSize.zero
//        }

        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        let itemsPerRow: CGFloat = 2 // 한 줄에 표현할 개수
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 1 // 총 row수
//        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let heightPadding = sectionInsets.top * (itemsPerColumn)
        
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

/// AppDelegate 에서 적용한 User Notification의 Delegate 메서드 구현
extension ListInTableViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let idToShow: String = response.notification.request.identifier
        
        guard let todoToShow: Todo = Todo.allTodo.first(where: { (todo: Todo) -> Bool in
            idToShow == todo.id
        }) else {
            return
        }
        
        guard let todosInTableViewController: TodosInTableViewController = self.storyboard?.instantiateViewController(identifier: TodosInTableViewController.storyboardID) else {
            return
        }
        
        guard let listToShow: List = List.listForID(todoToShow.listID) else { return }
        todosInTableViewController.list = listToShow
        todosInTableViewController.todoToShow = todoToShow
        
        self.navigationController?.pushViewController(todosInTableViewController, animated: true)
        
        completionHandler()
    }
}
