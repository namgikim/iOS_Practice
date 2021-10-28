//
//  TodoInTableViewController.swift
//  Reminders
//
//  Created by namgi on 2021/09/29.
//

import UIKit

class TodoInTableViewController: UIViewController {
    static let storyboardID: String = "TodoInTableViewController"
    
    // MARK: - Properties
    var list: List?
    var todo: Todo? {
        didSet {
            // todo.listID 값이 변경되었을 때, self.list 값을 갱신한다.
            if let todo: Todo = self.todo {
                self.list = List.listForID(todo.listID)
            }
        }
    }
//    var shouldSetCalendarHeight: Bool = false // 캘린더/시간 을 접을지 말지 제어하기 위한 변수
//    var shouldSetTimeHeight: Bool = false
    var isChanged: Bool = false // 어떤 값이든 edit가 시작되었다면 true로 설정하고,
                                //  취소 클릭 시 폐기 여부를 묻는다.
    
    let dateFormater: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    let timeDateFormater: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var successBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!

    // MARK: - IBActions
    @IBAction func touchUpSuccessBarButton(_ sender: UIBarButtonItem) {
        
        let isSuccess: Bool? = self.todo?.save {
            
            if let todo: Todo = self.todo {
                let userInfo: [String : Any] = [userInfoKeyDidEditDataNotification : "todo",
                                                userInfoKeyDidEditDataNotificationValue : todo]
                NotificationCenter.default.post(name: userDidEditDataNotificationName,
                                                object: nil,
                                                userInfo: userInfo)
                
                // 저장이 완료된 시점에서, 알림을 받았지만 완료되지 않은 알림 수를 체크하여 뱃지를 설정한다.
                if Todo.countTodoOfReceiveNotificationAndIsNotSuccess() == 0 {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = 1
                }
            }
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }

        if isSuccess == nil || isSuccess == false {
            popErrorMsgAlert("알림 저장에 오류가 발생했습니다. 다시 시도해주세요.") { (alert) in
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func touchUpCancelBarButton(_ sender: UIBarButtonItem) {
        
        self.dismissAfterAlert()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        self.navigationController?.presentationController?.delegate = self
        
        self.todoTableView.dataSource = self
        self.todoTableView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveUserDidSetTodoSettingNotification(_:)),
                                               name: userDidSetTodoSettingNotificationName,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 최초 한번은 tableView(_:heightForRowAt:) 에서 캘린더와 시간설정을 무조건 펼치지 않는다.
        // 다 그려진 다음부터는 펼칠 수 있다.
//        self.shouldSetCalendarHeight = true
//        self.shouldSetTimeHeight = true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showTodoInfoSetting" {
            guard let viewController: TodoInfoSettingTableViewController = segue.destination as? TodoInfoSettingTableViewController else { return }
            
            guard let cell: UITableViewCell = sender as? UITableViewCell else { return }
            guard let indexPath: IndexPath = self.todoTableView.indexPath(for: cell)
            else { return }
            
            viewController.todo = self.todo
        
            // 우선 순위 설정
            if indexPath.row == 0 {
                viewController.targetSetting = TodoInfoSettingTableViewController.Setting.priority
                
            // 목록 설정
            } else {
                viewController.targetSetting = TodoInfoSettingTableViewController.Setting.list
            }
        }
    }
}

extension TodoInTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return 4
        case 2:
            return 1
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var basicCell: UITableViewCell = UITableViewCell()
        
        guard let list: List = self.list else { return basicCell}
        guard let todo: Todo = self.todo else { return basicCell }
        
        switch indexPath.section {
        case 0:
            let cell: TodoInfoTextTableViewCell = tableView.dequeueReusableCell(withIdentifier: "textViewCell") as! TodoInfoTextTableViewCell
            
            if indexPath.row == 0 {
                cell.textView.text = todo.title
                
            } else if indexPath.row == 1 {
                cell.textView.text = todo.memo
            }
            
            cell.delegate = self
            
            basicCell = cell
        case 1...2:
            let cell: TodoInfoSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! TodoInfoSwitchTableViewCell
            
            let title: String
            let imageName: String
            
            // basicCell 에 담을 cell을 생성
            //   혹은 DatePickerCell 을 생성 후 바로 리턴
            // section 1
            if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    imageName = "calendar.circle.fill"
                    title = "날짜"
                    cell.actionSwitch.isOn = self.todo?.isUseDay ?? false
                    cell.logoImageView.tintColor = .systemRed
                    
                    if self.todo?.isUseDay == true {
                        cell.infoLabel.text = self.stringDateFormatter(self.todo?.due)["date"]
                    }
                    
                // DatePicker Cell 은 별도의 Cell 클래스로 Return 한다.
                } else if indexPath.row == 1 {
                    let datePickerCell: TodoInfoCalendarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "calendarCell") as! TodoInfoCalendarTableViewCell
                    
                    datePickerCell.delegate = self
                    
                    if self.todo?.isUseDay == true,
                       let due: Date = self.todo?.due {
                        datePickerCell.datePicker.date = due
                    }
                    
                    return datePickerCell
                
                // DatePicker Cell 은 별도의 Cell 클래스로 Return 한다.
                } else if indexPath.row == 3 {
                    let datePickerCell: TodoInfoTimeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "timeCell") as! TodoInfoTimeTableViewCell
                    
                    datePickerCell.delegate = self
                    
                    if self.todo?.isUseTime == true,
                       let due: Date = self.todo?.due {
                        datePickerCell.timeDatePicker.date = due
                    }
                    
                    return datePickerCell
                    
                } else { // row == 4
                    imageName = "clock.fill"
                    title = "시간"
                    cell.actionSwitch.isOn = self.todo?.isUseTime ?? false
                    cell.logoImageView.tintColor = .systemBlue
                    
                    if self.todo?.isUseTime == true {
                        cell.infoLabel.text = self.stringDateFormatter(self.todo?.due)["time"]
                    }
                }
                
            // section 2
            } else {
                imageName = "flag.circle.fill"
                title = "깃발"
                cell.actionSwitch.isOn = self.todo?.isFlag ?? false
                cell.logoImageView.tintColor = .systemOrange
            }
            
            cell.delegate = self
            cell.selectionStyle = .none
            cell.logoImageView?.image = UIImage(systemName: imageName)
            cell.titleLabel.text = title
            
            basicCell = cell
        default:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "nomalCell")!
            
            let text: String
            let detailText: String
            
            if indexPath.row == 0 {
                text = "우선 순위"
                detailText = Priority.priorityName(todo.priority)
            } else {
                text = "목록"
                detailText = list.title
            }
            
            cell.textLabel?.text = text
            cell.detailTextLabel?.text = detailText
            cell.detailTextLabel?.textColor = .darkGray
            
            basicCell = cell
        }
        
        return basicCell
    }
    
    // 섹션 별 로직을 구현한다.
    // TableView.rowHight 를 사용하면 자동으로 높이를 조정해준다.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        
        if indexPath.section == 0 {
            return UITableView.automaticDimension
            
        } else if indexPath.section == 1 {

            if indexPath.row == 1,
               let isUseDay: Bool = self.todo?.isUseDay {
                height = isUseDay ? self.todoTableView.rowHeight : 0.0
                
            } else if indexPath.row == 3,
                      let isUseTime: Bool = self.todo?.isUseTime {
                height = isUseTime ? self.todoTableView.rowHeight : 0.0
                
            } else { height = self.todoTableView.rowHeight }
            
        } else { height = self.todoTableView.rowHeight }
        
        return height
    }
    
}

extension TodoInTableViewController: TodoInfoSwitchTableViewCellDelegate {
    
    func settingSwitchChangedValue(_ sender: TodoInfoSwitchTableViewCell) {
        guard let indexPath: IndexPath = self.todoTableView.indexPath(for: sender) else { return }
        
        let cell: TodoInfoSwitchTableViewCell = self.todoTableView.cellForRow(at: indexPath) as! TodoInfoSwitchTableViewCell
        
        // 변경여부 O
        self.isChanged = true
        
        // 날짜/시간 스위치
        if indexPath.section == 1 {
            var reloadindexPaths: [IndexPath] = []
            
            // 날짜 switch 컨트롤
            if indexPath.row == 0 {
                self.todo?.isUseDay = cell.actionSwitch.isOn
                reloadindexPaths.append(IndexPath(row: 1, section: 1))
                
                // 날짜 설정을 on 했을 경우
                if self.todo?.isUseDay == true {
                    self.todo?.due = self.dateWithFixTime(Date())
                    
                // 날짜 설정을 off 했을 경우
                } else {
                    self.todo?.due = nil
                    
                    // 날짜 off 시, 시간도 off
                    if self.todo?.isUseTime == true {
                        
                        self.todo?.isUseTime = false
                        (self.todoTableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! TodoInfoSwitchTableViewCell).actionSwitch.isOn = false
                        
                        reloadindexPaths.append(IndexPath(row: 3, section: 1))
                    }
                }
                
            // 시간 switch 컨트롤
            } else if indexPath.row == 2 {
                self.todo?.isUseTime = cell.actionSwitch.isOn
                reloadindexPaths.append(IndexPath(row: 3, section: 1))
                
                // 시간 설정을 on 했을 경우
                if self.todo?.isUseTime == true {
                    
                    // 이미 시간 설정이 on 일 경우
                    if self.todo?.isUseDay == true {
                        let next: Date = self.dateWithNextTime(self.todo?.due ?? Date())
                        self.todo?.due = next
                        
                    // 아직 시간 설정이 off 일 경우
                    } else {
                        self.todo?.due = self.dateWithNextTime(Date())
                        
                        // 시간 설정을 on 한다.
                        self.todo?.isUseDay = true
                        (self.todoTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TodoInfoSwitchTableViewCell).actionSwitch.isOn = true
                        
                        reloadindexPaths.append(IndexPath(row: 1, section: 1))
                    }
                
                // 시간 설정을 off 했을 경우
                } else {
                    let fix: Date = self.dateWithFixTime(self.todo?.due ?? Date())
                    self.todo?.due = fix
                }
            }
            
            // DatePicker Row 펼치기
            self.todoTableView.performBatchUpdates({
                self.todoTableView.reloadRows(at: reloadindexPaths,
                                              with: .automatic)
            }, completion: nil)
            
            // Switch Cell 의 Label 설정
            (self.todoTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TodoInfoSwitchTableViewCell).infoLabel.text = self.stringDateFormatter(self.todo?.due)["date"]
            (self.todoTableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! TodoInfoSwitchTableViewCell).infoLabel.text = self.stringDateFormatter(self.todo?.due)["time"]
            
        // 깃발 스위치
        } else if indexPath.section == 2 {
            self.todo?.isFlag = cell.actionSwitch.isOn
        }
    }
    
}

extension TodoInTableViewController: TodoInfoTextTableViewCellDelegate {
    
    func todoTextViewDidChange(_ sender: TodoInfoTextTableViewCell) {
        guard let indexPath: IndexPath = self.todoTableView.indexPath(for: sender)
        else { return }
        
        // 변경여부 O
        self.isChanged = true
        
        // 제목 TextView
        if indexPath.row == 0 {
            let title: String = sender.textView.text
            
            // Update value of self.todo
            self.todo?.title = title
            
            // 완료버튼 활성화/비활성화
            if title.isEmpty == true { self.successBarButton.isEnabled = false }
            else { self.successBarButton.isEnabled = true}
            
        // 메모 TextView
        } else if indexPath.row == 1 {
            let memo: String = sender.textView.text
            
            if memo.isEmpty == false {
                // Update value of self.todo
                self.todo?.memo = memo
            }
        }
        
        // TableViewCell 안에 있는 TextView의 row 에 따른 높이 변화를 위한 설정
        let size: CGSize = sender.textView.bounds.size
        let newSize: CGSize = self.todoTableView.sizeThatFits(
            CGSize(width: size.width,
                   height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            self.todoTableView.beginUpdates()
            self.todoTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
    }
}

extension TodoInTableViewController: TodoInfoCalendarTableViewCellDelegate {
    
    func valueChangedDatePicker(_ sender: TodoInfoCalendarTableViewCell) {
        let date: Date = sender.datePicker.date
        let dateValues: [String : Int] = self.dateValues(date) // DatePicker 에서 추출
        
        // 변경여부 O
        self.isChanged = true
        
        guard let due : Date = self.todo?.due else {
            print("date - self.todo.due is nil")
            return
        }
        
        let dueValues: [String : Int] = self.dateValues(due) // self.todo.due 에서 추출
        
        let dateComponent: DateComponents = DateComponents(year: dateValues["year"],
                                                           month: dateValues["month"],
                                                           day: dateValues["day"],
                                                           hour: dueValues["hour"],
                                                           minute: dueValues["minute"])
        
        // Update value of self.todo
        self.todo?.due = Calendar.current.date(from: dateComponent)
        
        // Switch Cell 의 Label 설정
        let cell: TodoInfoSwitchTableViewCell = self.todoTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TodoInfoSwitchTableViewCell

        cell.infoLabel.text = self.stringDateFormatter(self.todo?.due)["date"]
    }
}

extension TodoInTableViewController: TodoInfoTimeTableViewCellDelegate {
    
    func valueChangedDatePicker(_ sender: TodoInfoTimeTableViewCell) {
        let time: Date = sender.timeDatePicker.date
        let timeValues: [String : Int] = self.dateValues(time) // DatePicker 에서 추출
        
        guard let due : Date = self.todo?.due else {
            print("time - self.todo.due is nil")
            return
        }
        
        // 변경여부 O
        self.isChanged = true
        
        let dueValues: [String : Int] = self.dateValues(due) // self.todo.due 에서 추출

        let dateComponent: DateComponents = DateComponents(year: dueValues["year"],
                                                           month: dueValues["month"],
                                                           day: dueValues["day"],
                                                           hour: timeValues["hour"],
                                                           minute: timeValues["minute"])
        
        // Update value of self.todo
        self.todo?.due = Calendar.current.date(from: dateComponent)
        
        // Switch Cell 의 Label 설정
        let cell: TodoInfoSwitchTableViewCell = self.todoTableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! TodoInfoSwitchTableViewCell

        cell.infoLabel.text = self.stringDateFormatter(self.todo?.due)["time"]
    }
}


extension TodoInTableViewController {
    
    // MARK: - Methods
    
    private func dismissAfterAlert() {
        
        if self.isChanged == true {
            popDiscardChangesAlert(discard: {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }) { (alert: UIAlertController) in
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Date 형식의 값을 년/월/일/시/분 으로 쉽게 접근할 수 있도록 Dictionary 리턴
    /// - Parameter date: 변환 할 Date 값
    /// - Returns: Dictionary 값
    private func dateValues(_ date: Date) -> [String : Int] {
        let year: Int = Calendar.current.component(.year, from: date)
        let month: Int = Calendar.current.component(.month, from: date)
        let day: Int = Calendar.current.component(.day, from: date)
        let hour: Int = Calendar.current.component(.hour, from: date)
        let minute: Int = Calendar.current.component(.minute, from: date)
        
        var result: [String: Int] = [:]
        result.updateValue(year, forKey: "year")
        result.updateValue(month, forKey: "month")
        result.updateValue(day, forKey: "day")
        result.updateValue(hour, forKey: "hour")
        result.updateValue(minute, forKey: "minute")
        
        return result
    }
    
    
    /// 우선순위, 목록 메뉴에서 부모 뷰의 self.todo 값을 변경한 뒤, 부모 뷰에 알린다.
    /// - Parameter noti: 우선순위, 목록 화면에서 post 요청한 한 Norification
    @objc private func didReceiveUserDidSetTodoSettingNotification(_ noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let settingName: String = userInfo[userInfoKeyDidSetTodoSettingNotification] as? String
        else { return }
        
        if settingName == "priority",
           let priority: Priority = userInfo[userInfoKeyDidSetTodoSettingNotificationValue] as? Priority {
            // Update value of self.todo
            self.todo?.priority = priority
            self.todoTableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .automatic)
            
        } else if settingName == "list",
                  let list: List = userInfo[userInfoKeyDidSetTodoSettingNotificationValue] as? List {
            // Update value of self.todo
            self.todo?.listID = list.id
            self.todoTableView.reloadRows(at: [IndexPath(row: 1, section: 3)], with: .automatic)
        }
        
        // 변경여부 O
        self.isChanged = true
    }
    
    
    /// 날짜/시간 스위치 좌측에 Label로 표시하기위해 String 으로 변환하는 메소드
    /// - Parameter date: 변환 할 Date 값
    /// - Returns: Dictionary 값
    private func stringDateFormatter(_ date: Date?) -> [String : String] {
        var result: [String : String] = ["date" : "", "time" : ""]
        var dateLabel: String = ""
        var timeLabel: String = ""
        
        if let due: Date = date {
            dateLabel = (self.todo?.isUseDay ?? false)
                        ? self.dateFormater.string(from: due) : ""
            timeLabel = (self.todo?.isUseTime ?? false)
                        ? self.timeDateFormater.string(from: due) : ""
        }
        
        result["date"] = dateLabel
        result["time"] = timeLabel
        
        return result
    }
    
    
    /// 전달 받은 날짜에 특정 시간을 고정하여 리턴한다.
    /// - Parameter date: 적용할 날짜
    /// - Returns: 특정 시간으로 설정된 날짜
    private func dateWithFixTime(_ date: Date) -> Date {
        let fixHour: Int = 9
        let dateValues: [String : Int] = self.dateValues(date)
        
        let dateComponents: DateComponents = DateComponents(year: dateValues["year"],
                                                            month: dateValues["month"],
                                                            day: dateValues["day"],
                                                            hour: fixHour,
                                                            minute: 0)
        
        guard let result: Date = Calendar.current.date(from: dateComponents)
        else { return date }
        
        return result
    }
    
    
    /// 전달 받은 날짜에 다가올 정시 시간으로 설정하여 리턴한다.
    /// - Parameter date: 적용할 날짜
    /// - Returns: 특정 시간으로 설정된 날짜
    private func dateWithNextTime(_ date: Date) -> Date {
        let dateValues: [String : Int] = self.dateValues(date)
        let todayValues: [String : Int] = self.dateValues(Date())
        
        let dateComponents: DateComponents = DateComponents(year: dateValues["year"],
                                                            month: dateValues["month"],
                                                            day: dateValues["day"],
                                                            hour: todayValues["hour"]! + 1,
                                                            minute: 0)
        
        guard let result: Date = Calendar.current.date(from: dateComponents) else { return date }
            
        return result
    }
}

extension TodoInTableViewController: UIAdaptivePresentationControllerDelegate {
    
    // 현재 컨트롤러를 delegate로 설정한 후 사용해야한다.
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.dismissAfterAlert()
    }
}
