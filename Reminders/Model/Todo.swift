//
//  Todo.swift
//  Reminders
//
//  Created by namgi on 2021/09/19.
//

import Foundation
import UserNotifications

struct Todo: Codable {
    var id: String
    var title: String
    var memo: String?
    var due: Date?
    var listID: String
    
    var isSuccess: Bool         // 완료여부
    var successDate: Date?      // 완료날짜
    var createDate: Date        // 생성날짜
    var isFlag: Bool            // 깃발여부
    var priority: Priority      // 우선순위도(없음/낮음/중간/높음)
    var menualTurn: Int         // 정렬 - 수동 순번
    
    var isUseDay: Bool          // due 의 날짜 저장 여부
    var isUseTime: Bool         // due 의 시간 저장 여부
    
    init(id: String, title: String, listID: String) {
        self.id = id
        self.title = title
        self.listID = listID
        
        self.isSuccess = false
        self.createDate = Date()
        self.isFlag = false
        self.priority = .none
        self.menualTurn = 0
        
        self.isUseDay = false
        self.isUseTime = false
    }
}

/**
 - Todo 배열 전역변수 선언 -> all
 - all 배열의 저장/삭제 로직을 구현하고 JSON 메소드까지 호출한다.
 */
extension Todo {
    static var allTodo: [Todo] = Todo.loadTodosFromJSONFile()
//    static var allTodo: [Todo] = [Todo(id: "1", title: "메모 1-1", memo: "메모 1-1 내용입니다.", due: Date(), listID: "1"), Todo(id: "2", title: "메모 1-2", memo: "메모 1-2 내용입니다.", due: Date(), listID: "1"), Todo(id: "3", title: "메모 1-3", memo: "메모 1-3 내용입니다.", due: Date(), listID: "1"), Todo(id: "4", title: "메모 2-1", memo: "메모 2-1 내용입니다.", due: Date(), listID: "2")]
    
    // save()
    func save(completion: () -> Void) -> Bool {        
        if let index: Int = Todo.allTodo.firstIndex(where: { (todo: Todo) -> Bool in
            todo.id == self.id
        }) {
            Todo.allTodo.replaceSubrange(index...index, with: [self])
        } else {
            Todo.allTodo.append(self)
        }
        
        let isSuccess: Bool = Todo.saveTodoToJSONFile()
        
        if isSuccess == true {
            Todo.removeNotification(id: self.id)
            
            if self.isUseDay == true,
               self.isSuccess == false,
               let due: Date = self.due,
               due > Date() {
                self.addNotification(self)
            }
            
            completion()
        }
        
        return isSuccess
    }
    
    func remove() -> Bool {
        
        guard let index: Int = Todo.allTodo.firstIndex(where: { (todo: Todo) -> Bool in
            todo.id == self.id
        }) else {
            return false
        }
        
        Todo.allTodo.remove(at: index)
        
        let isSuccess: Bool = Todo.saveTodoToJSONFile()
        
        Todo.removeNotification(id: self.id)
        
        return isSuccess
    }
    
    static func removeAll(at listID: String) -> Bool {
        
        Todo.allTodo.removeAll { (todo: Todo) -> Bool in
            if todo.listID == listID {
                Todo.removeNotification(id: todo.id) // Notification 도 삭제해준다.
                
                return true // 삭제.
            }
            return false
        }
        
        let isSuccess: Bool = Todo.saveTodoToJSONFile()
        
        return isSuccess
    }
}

/**
 - all 배열을 이용해서 JSON 데이터로 저장하고 불러온다.
 */
extension Todo {
    
    private static var todosPathURL: URL {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true).appendingPathComponent("todos.json")
    }
    
    private static func loadTodosFromJSONFile() -> [Todo] {
        
        do {
            let jsonData: Data = try Data(contentsOf: self.todosPathURL)
            let todos: [Todo] = try JSONDecoder().decode([Todo].self, from: jsonData)
            return todos
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    private static func saveTodoToJSONFile() -> Bool {
        
        do {
            let jsonData: Data = try JSONEncoder().encode(self.allTodo)
            try jsonData.write(to: self.todosPathURL, options: Data.WritingOptions.atomicWrite)
            return true
        } catch {
            print(error.localizedDescription)
        }
        
        return false
    }
}

extension Todo {
    
    // MARK: - Methods
    static func countAllTodo(withSuccessTodo: Bool) -> Int {
        return Todo.allTodo.filter { (todo: Todo) -> Bool in
            if withSuccessTodo == true { return true }
            else if todo.isSuccess == false { return true }
            
            return false
        }.count
    }
    
    static func countTodo(isFlag: Bool) -> Int {
        return Todo.allTodo.filter { (todo: Todo) -> Bool in
            
            if todo.isSuccess == false {
                
                if isFlag == true { return todo.isFlag }
                // else if ...
            }
            
            return false
        }.count
    }
    
    static func countTodoOfReceiveNotificationAndIsNotSuccess() -> Int {
        let result: Int
        
        result = Todo.allTodo.filter { (todo: Todo) -> Bool in
            
            if todo.isSuccess == false,
               todo.isUseDay == true,
               let due: Date = todo.due,
               due < Date() {
                return true
            }
            
            return false
        }.count
        
        return result
    }
    
    static func countTodoOfList(id: String, withSuccessTodo: Bool) -> Int {
        return self.todoOfList(id: id, withSuccessTodo: withSuccessTodo).count
    }
    
    static func todoOfList(id: String, withSuccessTodo: Bool) -> [Todo] {
        let todos: [Todo] = Todo.allTodo.filter { (todo: Todo) -> Bool in
            
            if todo.listID == id {
                if withSuccessTodo == true { return true }
                else if todo.isSuccess == false { return true }
            }
            
            return false
        }
        
        return todos
    }
    
    static func todoOfList(isFlag: Bool) -> [Todo] {
        let todos: [Todo] = Todo.allTodo.filter { (todo: Todo) -> Bool in
            
            if todo.isSuccess == false {
                
                if isFlag == true { return todo.isFlag }
                // else if ...
            }
            
            return false
        }
        
        return todos
    }
    
    static func allTodoWithCondition(list: List) -> [Todo] {
        var sortedTodos: [Todo]
        
        // 특별한 목록 외에는 Todo.todoOfList(id:withSuccessTodo:) 를 사용한다.
        if list.id == "002" {
            sortedTodos = Todo.todoOfList(isFlag: true)
        } else {
            sortedTodos = Todo.todoOfList(id: list.id,
                                          withSuccessTodo: list.showSuccessTodo)
        }
        
        let sub: SubSort = list.subSort
        
        sortedTodos.sort() {
            
            // 첫번째 조건
            if $0.isSuccess != $1.isSuccess {
                return ($0.isSuccess == true ? 1 : 0) < ($1.isSuccess == true ? 1 : 0)
                
            // 두번째 조건
            } else {
                
                switch list.sort {
                case .manual:
                    if $0.menualTurn != $1.menualTurn {
                        return $0.menualTurn < $1.menualTurn
                    } else {
                        return $0.createDate < $1.createDate
                    }
                case .due:
                    if let var0: Date = $0.due,
                       let var1: Date = $1.due {
                        if sub == .one { return var0 < var1 }
                        else { return var0 > var1 }
                    } else if let _: Date = $0.due {
                        return true
                    } else if let _: Date = $1.due {
                        return true
                    } else {
                        return $0.createDate < $1.createDate
                    }
                case .createDate:
                    if sub == .one { return $0.createDate < $1.createDate }
                    else { return $0.createDate > $1.createDate }
                case .priority:
                    if sub == .one { return $0.priority.rawValue < $1.priority.rawValue }
                    else { return $0.priority.rawValue > $1.priority.rawValue }
                case .title:
                    if sub == .one { return $0.title < $1.title }
                    else { return $0.title > $1.title}
                }
            }
        }
        
        return sortedTodos
    }
}

extension Todo {
    
    // MARK: - UserNotification
    private func addNotification(_ todo: Todo) {
        
        // 공용 UserNotification 객체
        let center = UNUserNotificationCenter.current()
        
        // Notification 콘텐츠 객체 생성
        let content = UNMutableNotificationContent()
        content.title = "할일 알림"
        content.body = todo.title
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // 기한 날짜 생성
        guard let due: Date = todo.due else { return }
        let dateInfo = Calendar.current.dateComponents([Calendar.Component.year,
                                                        Calendar.Component.month,
                                                        Calendar.Component.day,
                                                        Calendar.Component.hour,
                                                        Calendar.Component.minute], from: due)
        
        // Notification 트리거 생성
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // Notification 요청 객체 생성
        let requeset = UNNotificationRequest(identifier: todo.id,
                                             content: content,
                                             trigger: trigger)
        
        // Notification 스케줄 추가
        center.add(requeset) { (error: Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    private static func removeNotification(id: String) {
        let center = UNUserNotificationCenter.current()
        
        // Notification 요청 객체 삭제
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
