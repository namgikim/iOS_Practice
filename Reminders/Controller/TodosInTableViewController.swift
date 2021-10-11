//
//  TodosInTableViewController.swift
//  Reminders
//
//  Created by namgi on 2021/09/25.
//

import UIKit

class TodosInTableViewController: UIViewController {
    static let storyboardID: String = "TodosInTableViewController"

    // MARK: - Properties
    var list: List!
    var todos: [Todo] = []
    var successButtonWork: DispatchWorkItem?
    var todoToShow: Todo?
    
    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.short
        return formatter
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var todosTableView: UITableView!
    @IBOutlet var settingBarButton: UIBarButtonItem!
    @IBOutlet var successBarButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newTodoButton: UIBarButtonItem!
    @IBOutlet weak var newTodoButtonIcon: UIBarButtonItem!
    
    // MARK: - IBActions
    @IBAction func touchUpNewTodo(_ sender: UIBarButtonItem) {
        self.addRow()
    }
    @IBAction func tabBackground(_ sender: UITapGestureRecognizer) {
        
        // 최소 1개 이상의 목록이 필요함.
        if List.allListWithSort().count == 0 {
            
            popInformMsgAlert(title: "목록 없음", 
                              message: "먼저 목록을 생성한 후 다시 시도하십시오.") { (alert) in
                self.present(alert, animated: true, completion: nil)
            } dismiss: {
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.topViewController?.performSegue(withIdentifier: "showAddList", sender: nil)
            }

            return
        }
        
        // 수정 중 인지 체크
        var isEditing: Bool = false
        for index in 0..<self.todos.count {
            let cell: TodoTableViewCell = self.todosTableView.cellForRow(at: IndexPath(row: index, section: 0)) as! TodoTableViewCell
            
            if cell.titleTextView.isFirstResponder == true {
                isEditing = true
                break
            }
        }
        
        // 수정 중이면 에디트 종료
        // 아니면 addRow
        if isEditing == true {
            self.view.endEditing(true)
            
        } else {
            self.addRow()
        }
    }
    
    @IBAction func touchUpSeccessBarButton(_ sender: UIBarButtonItem) {
        
        // 일단, 에디트 종료 시키기
        //   일괄 선택 후 처리할 때는 다른 동작이 되어야 함.
        self.view.endEditing(true)
    }
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View Protocol 채택
        self.todosTableView.delegate = self
        self.todosTableView.dataSource = self
        
        // 초기화
        self.loadTodos()               // self.todos 값 갱신
        self.setTitle {
            self.setColor()
        }      // 타이틀 설정
        self.setBarButton(isEditing: false) // Right Bar Button 아이템 설정
        self.setSettingPulldownMenu()       // 설정 Bar Button 내부의 메뉴 목록 초기화
        self.setAddTodoBarButton()          // 알림추가버튼 활성화 여부
        
        // Notification Observer 추가
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveUserDidEditDataNotification(_:)),
                                               name: userDidEditDataNotificationName,
                                               object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 사용자가 UserNotification 알림을 클릭했을 때, 해당 알림을 하이라이트 처리
        if let todoToShow = self.todoToShow,
           let index: Int = self.todos.firstIndex(where: { (todo: Todo) -> Bool in
            todo.id == todoToShow.id
           }),
           let cell: TodoTableViewCell = self.todosTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TodoTableViewCell {
            
            cell.selectionStyle = .default
            cell.isHighlighted = true
            cell.titleTextView.backgroundColor = .systemGray4
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                cell.isHighlighted = false
                cell.selectionStyle = .none
                cell.titleTextView.backgroundColor = .none
            }
        }
        self.todoToShow = nil // 초기화
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // self.performSegue(withIdentifier:sender:) 을 호출하면 이 메소드가 동일하게 실행된다.
        //  withIdentifier: segue.identifier
        //  sender: cell
        
        if segue.identifier == "showTodoInfo" {
            guard let navigationController: UINavigationController = segue.destination as? UINavigationController else { return }
            
            guard let viewController: TodoInTableViewController = navigationController.topViewController as? TodoInTableViewController else { return }
            
            guard let cell: TodoTableViewCell = sender as? TodoTableViewCell else { return }
            
            guard let indexPath: IndexPath = self.todosTableView.indexPath(for: cell) else { return }
            
            // tableView(_:accessoryButtonTappedForRowWith:) 에서 동작하고자 했던 로직을 이곳으로 이동시킴. (-> prepare()이 더 먼저 동작함.)
            if cell.titleTextView.text.isEmpty == true {
                cell.titleTextView.text = "새로운 미리 알림"
            }
            self.view.endEditing(true)
            
            let todo: Todo = self.todos[indexPath.row]
            viewController.list = self.list
            viewController.todo = todo
        }
    }

}

extension TodosInTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // (참고: viewDidAppear() 메소드가 호출 된 후에 동작한다.)

        let cell: TodoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoTableViewCell
        
        cell.delegate = self

        if self.todos.count <= indexPath.row { return cell }
        
        cell.titleTextView.text = self.todos[indexPath.row].title
        cell.successButton.isSelected = self.todos[indexPath.row].isSuccess
        
        // 완료 버튼에 색상을 입힌다.
        if let color: Int = self.list.color {
            cell.successButton.tintColor = cell.successButton.isSelected
                                            ? colors[color] : .darkGray
        }
        
        // 알림 설정 시, 시간이 경과된 경우 빨간글씨로 표기한다.
        if self.todos[indexPath.row].isUseDay == true,
           self.todos[indexPath.row].isSuccess == false,
           let due: Date = self.todos[indexPath.row].due,
           due < Date() {
            cell.titleTextView.textColor = .red
        } else {
            cell.titleTextView.textColor = .black
        }

        cell.accessoryType = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(20))
        header.textLabel?.textColor = UIColor.systemBlue
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var todo: Todo = self.todos[indexPath.row]

        /**
         알림 별 세부사항을 보여주는 모달을 띄운다.
         */
        let infoAction: UIContextualAction
        infoAction = UIContextualAction(style: UIContextualAction.Style.normal,
                                        title: "세부사항",
                                        handler: { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                                            
                                            let cell: TodoTableViewCell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
                                            
                                            self.performSegue(withIdentifier: "showTodoInfo", sender: cell)
                                            
                                            success(true)
                                        })
        infoAction.backgroundColor = .systemGray
        
        let flagAction: UIContextualAction
        flagAction = UIContextualAction(style: .normal,
                                        title: todo.isFlag == false ? "깃발" : "깃발 제거",
                                        handler: { (UIContextualAction, UIView, success: @escaping (Bool) -> Void ) in
                                            
                                            let flag: Bool = !todo.isFlag
                                            todo.isFlag = flag
                                            self.save(todo, indexPath: indexPath)
                                            
                                            success(true)
                                        })
        flagAction.backgroundColor = .systemOrange
        
        let deleteAction: UIContextualAction
        deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive,
                                          title: "삭제",
                                          handler: { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                                            
                                            self.remove(todo, indexPath: indexPath)
                                            
                                            success(true)
                                          })
        
        let config: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, flagAction, infoAction])
        return config
    }
    
    // prepare() 보다 늦게 실행되기 때문에, 해당 로직은 prepare()로 이동시킨다.
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        let cell: TodoTableViewCell = self.todosTableView.cellForRow(at: indexPath) as! TodoTableViewCell
//
//        if cell.titleTextView.text.isEmpty == true {
//            cell.titleTextView.text = "새로운 미리 알림"
//        }
//
//        self.view.endEditing(true)
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // TableViewCell 안에 있는 TextView의 row 에 따른 높이 변화를 위한 설정
        return UITableView.automaticDimension
    }
}

extension TodosInTableViewController {
    
    // MARK: - Methods
    
    /// allTodo 에서 현재 목록에 해당하는 알림을 가져온다.
    private func loadTodos() {
        let todos: [Todo] = Todo.allTodoWithCondition(list: self.list)
        
        self.todos = todos
    }
    
    /// 새로운 미리 알림을 추가한다.
    private func addRow() {
        
        // 깃발 목록 등, 특수한 목록에서 알림을 생성할 경우 목록id를 별도로 지정한다.
        let listID: String
        let isFlag: Bool
        if let listTuple : ListTuple = listTuples.first(where: { (tuple) -> Bool in
            tuple.id == self.list.id
        }) {
            listID = List.allListWithSort()[0].id
            isFlag = listTuple.name == "flagListTuple" ? true : false
        } else {
            listID = self.list.id
            isFlag = false
        }
        
        var todo: Todo = Todo(id: String(Date().timeIntervalSince1970),
                              title: "",
                              listID: listID)
        todo.isFlag = isFlag
        
        let indexPath: IndexPath = IndexPath(row: self.todos.count, section: 0)
        self.todos.append(todo)
        
        // self.tebleView.reloadDate() 는 데이터 전체를 다시 로드하기 때문에, 많은 데이터에는 비효율적이다.
        self.todosTableView.performBatchUpdates({
            self.todosTableView.insertRows(at: [indexPath],
                                      with: UITableView.RowAnimation.automatic)
        }, completion: nil)
        
        let _ = todo.save {
            print("임시 저장 완료")
        }
        
        let cell: TodoTableViewCell = self.todosTableView.cellForRow(at: indexPath) as! TodoTableViewCell
        cell.titleTextView.becomeFirstResponder()
    }
    
    
    /// 각 Todo의 save()로 저장하고, completion 메소드를 구현한다.
    /// - Parameters:
    ///   - todo: 저장하는 알림 정보
    ///   - indexPath: todo에 해당하는 cell 정보
    private func save(_ todo: Todo, indexPath: IndexPath) {
        let isSuccess: Bool = todo.save {
            print("todo 저장 완료 (title: \(todo.title))")
            
            self.loadTodos() // self.todos 값 갱신
            self.todosTableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
        
        if isSuccess == false {
            print("todo 저장 실패")
        }
    }
    
    
    /// 각 Todo의 remove()로 삭제하고, row cell 도 반영한다.
    /// - Parameters:
    ///   - todo: 삭제할 알림 정보
    ///   - indexPath: cell 정보
    private func remove(_ todo: Todo, indexPath: IndexPath) {
        let isSuccess: Bool = todo.remove()
        
        if isSuccess == true {
            print("todo 삭제 완료 (title: \(todo.title))")
            
            // 별도의 체크없이 바로 삭제해도 무방항.
            self.removeRow(at: indexPath)
            
        } else {
            print("todo 삭제 실패")
        }
    }
    
    /**
     설정 버튼을 클릭 시 나타나는 메뉴를 구성한다.
     - UIMenu > options
        - 작성하지 않기: 하위메뉴가 새로운 팝업으로 보여준다.
        - displayInline: 하위메뉴를 펼쳐서 바로 보여준다.
     - UIMenu, UIAction
        - 필요 없는 파라미터는 작성하지 않아도 된다. (자동 작성되는 파라미터를 굳이 모두 채울 필요는 없다.
     */
    private func setSettingPulldownMenu() {
        
        // MARK: Pull-Down Menus
        var menus: [UIMenuElement] = []
        
        if self.list.isShow == true {
            let modalListView = UIAction(title: "이름 및 모양",
                                         image: UIImage(systemName: "pencil"),
                                         state: UIMenuElement.State.off) { (UIAction) in
                
                popModalListViewController(self, editList: self.list)
            }
            menus.append(modalListView)
        }
//        let select = UIAction(title: "미리 알림 선택",
//                                     image: UIImage(systemName: "checkmark.circle"),
//                                     state: UIMenuElement.State.off) { (UIAction) in
//            print("Test")
//        }
//        menus.append(select)
        
        let sort = UIMenu(title: "다음으로 정렬",
                          image: UIImage(systemName: "arrow.up.arrow.down"),
                          children: self.getSortPulldownMenu())
        menus.append(sort)
        
        let finishedTodos = UIAction(title: self.list.showSuccessTodo == true ? "완료된 항목 가리기" : "완료된 항목 보기",
                                     image: UIImage(systemName: self.list.showSuccessTodo == true ? "eye.slash" : "eye"),
                                     identifier: UIAction.Identifier(rawValue: "test"),
                                     state: .off) { (UIAction) in
            
            self.list.showSuccessTodo = !self.list.showSuccessTodo
            let isSuccess = self.list.save {
                print("List의 완료된 항목 보기 메뉴 저장 완료")
                
                self.reloadWithPulldownMenu()
            }
            
            if isSuccess == false {
                print("List의 완료된 항목 보기 메뉴 저장 실패")
            }
        }
        menus.append(finishedTodos)
        
        if self.list.isShow == true {
            let removeList = UIAction(title: "목록 삭제",
                                         image: UIImage(systemName: "trash"),
                                         attributes: UIMenuElement.Attributes.destructive,
                                         state: UIMenuElement.State.off) { (UIAction) in
                
                if Todo.countTodoOfList(id: self.list.id, withSuccessTodo: true) == 0 {
                    let isSuccess = self.list.remove()
                    if isSuccess == true {
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    } else {
                        print("목록 삭제 실패")
                    }
                    
                } else {
                    let alert: UIAlertController = getlistDeleteAlert(list: self.list) {
                        let isSuccess = self.list.remove()
                        if isSuccess == true {
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        } else {
                            print("목록 삭제 실패")
                        }
                    }
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            menus.append(removeList)
        }
        
        self.settingBarButton.menu = UIMenu(title: "",
                                            options: UIMenu.Options.displayInline,
                                            children: menus)
    }
    
    
    /// '다음으로 정렬' 메뉴의 하위 메뉴를 구한다.
    /// - Returns: 하위 메뉴 배열 리턴
    private func getSortPulldownMenu() -> [UIMenuElement] {
        var sorts: [UIMenuElement] = []
        
        
        /// 각 하위 메뉴를 클릭했을 때의 공통 로직을 처리한다.
        /// 선택 값을 저장하고 PulldownMenu 전체를 재 셋팅한다.
        /// - Parameter sort: 클릭한 하위 메뉴
        func exec(_ sort: Sort) {
            self.list.sort = sort
            
            // '수동'일 경우 none 저장. 그 외에는 첫번째 서브 정렬을 기본값으로 한다.
            if sort == .manual {
                self.list.subSort = .none
                
            } else {
                self.list.subSort = .one
            }
            
            let isSuccess = self.list.save {
                print("List의 정렬 메뉴 저장 완료")
                self.reloadWithPulldownMenu()
            }
            
            if isSuccess == false {
                print("List의 정렬 메뉴 저장 실패")
            }
        }
        
        let manual: UIAction = UIAction(title: "수동",
                                        state: self.list.sort == .manual ? .on : .off) { (UIAction) in
            exec(.manual)
        }
        let due: UIAction = UIAction(title: "마감일",
                                            state: self.list.sort == .due ? .on : .off) { (UIAction) in
            exec(.due)
        }
        let createDate: UIAction = UIAction(title: "생성일",
                                            state: self.list.sort == .createDate ? .on : .off) { (UIAction) in
            exec(.createDate)
        }
        let priority: UIAction = UIAction(title: "우선 순위",
                                        state: self.list.sort == .priority ? .on : .off) { (UIAction) in
            exec(.priority)
        }
        let titleText: UIAction = UIAction(title: "제목",
                                           state: self.list.sort == .title ? .on : .off) { (UIAction) in
            exec(.title)
        }
        
        sorts.append(manual)
        sorts.append(due)
        sorts.append(createDate)
        sorts.append(priority)
        sorts.append(titleText)
        
        // 하위 메뉴의 2차 하위 메뉴를 구한다.
        if let subSort: UIMenu = self.getSubSortPulldownMenu() {
            sorts.append(subSort)
        }
        
        return sorts
    }
    
    
    /// 하위 메뉴의 2차 하위 메뉴를 구한다.
    /// 메뉴에 담아 리턴한다. 그대신 UIMenu.Options.displayInline 형식으로 보여주며,
    /// 하단 부분에 파티션이 생기며 보여주게 된다.
    /// - Returns: 메뉴 리턴
    private func getSubSortPulldownMenu() -> UIMenu? {
        var oneSubSortTitle: String
        var twoSubSortTitle: String
        
        /// 각 하위 메뉴의 2차 하위 메뉴를 클릭했을 때의 공통 로직을 처리한다.
        /// 선택 값을 저장하고 PulldownMenu 전체를 재 셋팅한다.
        /// - Parameter subSort: 클릭한 하위 메뉴의 2차 하위 메뉴
        func exec(_ subSort: SubSort) {
            self.list.subSort = subSort
            
            let isSuccess = self.list.save {
                print("List의 정렬 - 서브 메뉴 저장 완료")
                self.reloadWithPulldownMenu()
            }
            
            if isSuccess == false {
                print("List의 정렬 - 서브 메뉴 저장 실패")
            }
        }
        
        switch self.list.sort {
        case .due:
            oneSubSortTitle = "이른 항목 순으로"
            twoSubSortTitle = "최신 항목 순으로"
        case .createDate:
            oneSubSortTitle = "오래된 항목 순으로"
            twoSubSortTitle = "최신 항목 순으로"
        case .priority:
            oneSubSortTitle = "낮은 우선 순위로"
            twoSubSortTitle = "높은 우선 순위로"
        case .title:
            oneSubSortTitle = "오름차순"
            twoSubSortTitle = "내림차순"
        default:
            oneSubSortTitle = ""
            twoSubSortTitle = ""
        }
            
        if oneSubSortTitle != "", twoSubSortTitle != "" {
            
            // 2차 하위 메뉴는 열거형의 특정 이름 없이 one, two, .. 로 표현한다.
            let oneSubSort = UIAction(title: oneSubSortTitle,
                                  state: self.list.subSort == .one ? .on : .off,
                                  handler: { (UIAction) in
                exec(.one)
            })
            let twoSubSort = UIAction(title: twoSubSortTitle,
                                  state: self.list.subSort == .two ? .on : .off,
                                  handler: { (UIAction) in
                exec(.two)
            })
            
            let menu: UIMenu = UIMenu(title: "",
                                      image: nil,
                                      options: UIMenu.Options.displayInline,
                                      children: [oneSubSort, twoSubSort])
            
            return menu
            
        } else {
            return nil
        }
    }
    
    
    /// PulldownMenu를 재 설정하고 이를 반영하여, TableView를 reload한다.
    private func reloadWithPulldownMenu() {
        self.setSettingPulldownMenu()
        
        self.loadTodos() // self.todos 값 갱신
        self.todosTableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.automatic)
    }
    
    /**
     상단의 목록 이름을 설정한다.
     */
    private func setTitle(completion: () -> Void) {
        self.titleLabel.text = self.list.title
        
        completion()
    }
    
    private func setColor() {
        
        if let color: Int = self.list.color {
            self.titleLabel.textColor = colors[color]
            self.newTodoButton.tintColor = colors[color]
            self.newTodoButtonIcon.tintColor = colors[color]
        }
    }
    
    /**
     '이름 및 모양' 메뉴로 변경한 내역을 반영한다.
     */
    @objc private func didReceiveUserDidEditDataNotification(_ noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let action: String = userInfo[userInfoKeyDidEditDataNotification] as? String else { return }
        
        if action == "list" {
            guard let list: List = userInfo[userInfoKeyDidEditDataNotificationValue] as? List else { return }
            self.list = list
            self.setTitle {
                self.setColor()
            }
            
        } else if action == "todo" {
            guard let todo: Todo = userInfo[userInfoKeyDidEditDataNotificationValue] as? Todo else { return }
            
            for row in 0..<self.todos.count {
                if self.todos[row].id == todo.id {
                    
                    self.loadTodos()
                    self.todosTableView.reloadSections(IndexSet(integer: 0), with: .none)
                    
                    break
                }
            }
        }
    }
    
    
    /// TableView 의 row 를 제거하고, 그에 맞게 배열 데이터로 수정한다.
    /// 각 row 를 제어할 때는 전체를 reload 하는 것보다, 각 Row를 insert/delete 하는것이 자연스럽다.
    /// - Parameter indexPath: 제거할 Row
    private func removeRow(at indexPath: IndexPath) {
        // 데이터 제거
        self.todos.remove(at: indexPath.row)
        
        // row 제거
        self.todosTableView.performBatchUpdates({
            self.todosTableView.deleteRows(at: [indexPath],
                                      with: UITableView.RowAnimation.automatic)
        }, completion: nil)
    }
    
    
    /// self.todos에서 row로 찾은 정보와 실제 참조중인 정보가 일치한지 체크
    /// 저장된 정보는 id로 확실히 체크한 후 제거하는 것이 좋다.
    /// - Parameters:
    ///   - indexPath: self.todos에서 정보를 찾을 값
    ///   - todo: 실제 참조중인 정보
    /// - Returns: id 값 일치여부
    private func validateIndexPathToTodo(indexPath: IndexPath, todo: Todo) -> Bool{
        let todoCheck: Todo = self.todos[indexPath.row]
        
        if todoCheck.id == todo.id {
            return true
        }
        
        return false
    }
    
    /// 수정중인지 아닌지에 따라 Bar Button 의 완료버튼과 설정버튼을 번갈아 보여준다.
    /// - Parameter isEditing: 수정을 시작했는지 혹은 끝났는지에 대한 값
    private func setBarButton(isEditing: Bool) {
        
        self.navigationItem.rightBarButtonItems = nil
        
        let rightBarButtonItem: UIBarButtonItem
        
        // 수정 시작
        if isEditing == true {
            rightBarButtonItem = self.successBarButton
            
        // 수정 끝
        } else {
            rightBarButtonItem = self.settingBarButton
        }
        
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
    }
    
    private func setAddTodoBarButton() {
        newTodoButton.isEnabled = List.allListWithSort().count == 0 ? false : true
        newTodoButtonIcon.isEnabled = List.allListWithSort().count == 0 ? false : true
    }
}

extension TodosInTableViewController: TodoTableViewCellDelegate {

    // MARK: - TodoTableViewCellDelegate Methods
    /// Cell의 TextView 작성을 시작하는 시점에 이 메소드를 실행시켜 우측 상단의 Bar Button 표시여부를 동작한다.
    /// - Parameter sender: Table View Cell
    func todoCellBeginEditing(_ sender: TodoTableViewCell) {
        
        // 초기 설정
        self.setBarButton(isEditing: true)
        sender.accessoryType = .detailButton // 수정을 시작하면 보여준다. 수정이 끝나면 감춘다.
        
        // accesoryType 대신에 accessotyView 를 사용한다.
        // accessory 버튼을 새롭게 정의한다. (색상 입히기 위함)
//        let infoImage: UIImage? = UIImage(systemName: "info.circle")
//        let widthInfoImage: CGFloat = (infoImage?.size.width)! + 8
//        let heightInfoImage: CGFloat = (infoImage?.size.height)! + 8
//        let detail: UIImageView = UIImageView(
//            frame: CGRect(x: 0,
//                          y: 0,
//                          width: widthInfoImage,
//                          height: heightInfoImage
//            ))
//        detail.image = infoImage
//        if let color: Int = self.list.color {
//            detail.tintColor = colors[color]
//        } else {
//            detail.tintColor = colors[6]
//        }
//        sender.accessoryView = detail
    }
    
    // Cell 의 TextView 작성을 완료하는 시점(TodoTableViewCell.swift에 작성)에 이 메소드를 실행시켜 해당 알림에 대한 동작을 수행한다.
    func todoCellEndEditing(_ sender: TodoTableViewCell) {
        
        // 초기 설정
        self.setBarButton(isEditing: false)
        sender.accessoryType = .none // 수정을 시작하면 보여준다. 수정이 끝나면 감춘다.
//        sender.accessoryView = .none
        
        guard let indexPath: IndexPath = self.todosTableView.indexPath(for: sender) else { return }
        
        if indexPath.row >= self.todos.count { return }
        
        var todo: Todo = self.todos[indexPath.row]
        
        // 입력 값이 있다면 저장
        if let title: String = sender.titleTextView.text,
           title.isEmpty == false {
            
            // Custom Cell 의 각 객체에 작성한 값을 Todo 객체에 옯긴다.
            todo.title = title
            
            self.save(todo, indexPath: indexPath)
            
        // 입력 값이 없다면, 해당 row 바로 제거
        } else {
            let isSuccess: Bool = todo.remove()
            if isSuccess == true {
                print("임시 저장 삭제 완료")
                self.removeRow(at: indexPath)
            }
        }
    }
    
    // cell의 완료버튼을 클릭 시 동작하는 메소드
    // !!> todoCellEndEditing(_:) 보다 먼저 실행이 시작되고 완료까지 된다.
    //  임의로 에디트를 종료해야한다. (self.view.endEditing(true))
    // !!> 시점 확인 잘 하자!!
    func todoCellTouchUpSuccessButton(_ sender: TodoTableViewCell) {
        self.view.endEditing(true)
        
        // 각 row 의 isSelected 값을 저장한다.
        if let indexPath: IndexPath = self.todosTableView.indexPath(for: sender) {
            self.todos[indexPath.row].isSuccess = sender.successButton.isSelected
            self.todos[indexPath.row].successDate = sender.successButton.isSelected
                                                    ? Date() : nil
            
            if let color: Int = self.list.color {
                sender.successButton.tintColor = sender.successButton.isSelected ? colors[color] : .darkGray
            }
            
            let isSuccess: Bool = self.todos[indexPath.row].save {
                print("todo 완료여부 저장 완료")
                
                // 저장이 완료된 시점에서, 알림을 받았지만 완료되지 않은 알림 수를 체크하여 뱃지를 설정한다.
                if Todo.countTodoOfReceiveNotificationAndIsNotSuccess() == 0 {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = 1
                }
            }
            
            if isSuccess == false {
                print("todo 완료여부 저장 실패")
            }
        }
        
        // 이미 work가 있다면, 제거.
        if let work: DispatchWorkItem = self.successButtonWork {
            work.cancel()
            
            self.successButtonWork = nil
        }
        
        // work 할당
        //  '완료된 항목 보기'시 3초 뒤 해당 row를 제거해주는 로직
        if self.list.showSuccessTodo == false {
            
            self.successButtonWork = DispatchWorkItem(block: {
                print("Ready remove rows...")
                
                self.loadTodos()
                
                // 삭제할 indexPath 를 구한다.
                var deleteIndexPaths: [IndexPath] = []
                
                let cells: [TodoTableViewCell] = self.todosTableView.visibleCells as! [TodoTableViewCell]
                for cell in cells {
                    guard let indexPath: IndexPath = self.todosTableView.indexPath(for: cell) else { return }
                    
                    // 3초 뒤에 이 구문이 실행되는 시점에서 완료버튼 누른 알림을 찾는다.
                    if cell.successButton.isSelected == true {
                        deleteIndexPaths.append(indexPath)
                    }
                }
                
                // 해당 row를 삭제한다.
                if deleteIndexPaths.count > 0 {
                    self.todosTableView.performBatchUpdates({
                        self.todosTableView.deleteRows(at: deleteIndexPaths,
                                                       with: UITableView.RowAnimation.automatic)
                    }) { (Bool) in
                        print("Success remove rows (\(deleteIndexPaths.count))")
                    }
                    
                } else {
                    print("There are no rows to delete...")
                }
                
                // 해당 work는 초기화한다.
                self.successButtonWork = nil
            })
            
            guard let work: DispatchWorkItem = self.successButtonWork else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
            
        } else {
            self.loadTodos()
            self.todosTableView.beginUpdates()
            self.todosTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.todosTableView.endUpdates()
        }
    }
    
    
    /// TableViewCell 안에 있는 TextView의 row 에 따른 높이 변화를 위한 메소드
    /// - Parameter sender: cell
    func todoCellDidChange(_ sender: TodoTableViewCell) {
        let size: CGSize = sender.titleTextView.bounds.size
        let newSize = sender.titleTextView.sizeThatFits(
            CGSize(width: size.width,
                   height: CGFloat.greatestFiniteMagnitude))
        
        //print("newSize: \(newSize)")
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false) // 휙휙 row가 변화되도록 보이기 위해 animation 제거
            self.todosTableView.beginUpdates() // row 갱신효과
            self.todosTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}
