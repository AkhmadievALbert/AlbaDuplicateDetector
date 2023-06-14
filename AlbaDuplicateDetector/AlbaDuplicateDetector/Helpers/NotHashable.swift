//
//  NotHashable.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 11.06.2023.
//

import Foundation

@propertyWrapper
struct NotHashable<Value: Codable>: Equatable, Hashable, Codable {
    var wrappedValue: Value

    init(wrappedValue value: Value) {
        self.wrappedValue = value
    }

    func hash(into hasher: inout Hasher) {}

    static func == (lhs: NotHashable<Value>, rhs: NotHashable<Value>) -> Bool {
        true
    }
}
