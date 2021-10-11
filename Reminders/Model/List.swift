//
//  List.swift
//  Reminders
//
//  Created by namgi on 2021/09/19.
//

import Foundation

protocol ListDelegate {
    func listDidEdit()
}

struct List: Codable {
    var id: String
    var title: String
    var isShow: Bool = true
    
    var showSuccessTodo: Bool
    var sort: Sort
    var subSort: SubSort
    
    var turn: Int //정렬 순번
    
    var color: Int? = 2 // 2: systemOrange
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
        self.showSuccessTodo = false
        self.sort = .manual
        self.subSort = .none
        self.turn = 0
    }
}

/**
 - 배열 전역변수를 선언하고 저장/삭제를 구현한다.
 - 또한, JSON 메소드를 호출하여 JSON 데이터로 저장한다.
 */
extension List {
    
    static var delegate: ListDelegate?
    
    static var allList: [List] = List.loadListFromJSONFile() {
        didSet {
            delegate?.listDidEdit() // ListInTableViewController.swift 에 구현함.
        }
    }
//    static var allList: [List] = [List(id: "1", title: "미리 알림"), List(id: "2", title: "약 복용 알림"), List(id: "3", title: "운동 알림")]
    
    func save(completion: () -> Void) -> Bool {
        
        if let index: Int = List.allList.firstIndex(where: { (list) -> Bool in
            self.id == list.id
        }) {
            List.allList.replaceSubrange(index...index, with: [self])
        } else {
            List.allList.append(self)
        }
        
        let isSuccess: Bool = List.saveListToJSONFile()
            
        if isSuccess == true {
            completion()
        }
        
        return isSuccess
    }
    
    func remove() -> Bool {
        
        guard let index: Int = List.allList.firstIndex(where: { (list: List) -> Bool in
            list.id == self.id
        }) else {
            return false
        }
        
        List.allList.remove(at: index)
        let isSuccessList: Bool = List.saveListToJSONFile()
        
        let isSuccessTodo: Bool = Todo.removeAll(at: self.id)
        
        return isSuccessList && isSuccessTodo
    }
}

/**
 - List 배열을 이용해서 JSON 데이터로 저장하고 불러온다.
 */
extension List {
    
    private static var listPathURL: URL {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true).appendingPathComponent("list.json")
    }
    
    private static func loadListFromJSONFile() -> [List] {
        
        do {
            let jsonData: Data = try Data(contentsOf: self.listPathURL)
            let list: [List] = try JSONDecoder().decode([List].self, from: jsonData)
            
            return list
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    private static func saveListToJSONFile() -> Bool {
        
        do {
            let jsonData: Data = try JSONEncoder().encode(self.allList)
            try jsonData.write(to: self.listPathURL, options: Data.WritingOptions.atomicWrite)
            return true
        } catch {
            print(error.localizedDescription)
        }
        
        return false
    }
    
}

extension List {
    
    // MARK: - Methods
    
    /// 깃발 등 초기 목록 생성
    static func initializeList() {
  
        for i in 0..<listTuples.count {
            var list: List = List(id: listTuples[i].id, title: listTuples[i].title)
            list.isShow = listTuples[i].isShow
            
            if List.listForID(list.id) == nil {
                let isSuccess: Bool = list.save {
                    print("초기화: <\(list.title)> 목록 생성 완료")
                }
                
                if isSuccess == false { print("초기화: <\(list.title)>목록 생성 실패...")}
                
            } else {
                print("초기화: <\(list.title)>목록 이미 존재함.")
            }
        }
    }
    
    static func allListWithSort() -> [List] {
        var lists: [List] = List.allList.filter { (list: List) -> Bool in
            return list.isShow
        }
        
        lists.sort {
            $0.turn < $1.turn
        }
        
        return lists
    }
    
    static func listForID(_ id: String) -> List? {
        if let list: List = List.allList.first(where: { (list: List) -> Bool in
            id == list.id
        }) {
            return list
        } else {
            return nil
        }
    }
}
