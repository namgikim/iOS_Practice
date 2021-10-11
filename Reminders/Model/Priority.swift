//
//  Priority.swift
//  Reminders
//
//  Created by namgi on 2021/09/30.
//

import Foundation

enum Priority: Int, Codable {
    case none = 101
    case low, middle, high
    
    static func priorityName(_ priority: Priority) -> String {
        var result: String
        
        switch priority {
        case .none:
            result = "없음"
        case .low:
            result = "낮음"
        case .middle:
            result = "중간"
        case .high:
            result = "높음"
        }
        
        return result
    }
}
