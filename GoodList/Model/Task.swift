//
//  Task.swift
//  GoodList
//
//  Created by Taisei Sakamoto on 2021/03/05.
//

import Foundation

enum Priority: Int {
    case high
    case medium
    case low
}

struct Task {
    let title: String
    let priority: Priority
}
