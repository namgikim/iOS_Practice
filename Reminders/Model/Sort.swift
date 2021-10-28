//
//  Sort.swift
//  Reminders
//
//  Created by namgi on 2021/09/26.
//

import Foundation

enum Sort: Int, Codable {
    case manual = 101
    case due, createDate, priority, title
}
