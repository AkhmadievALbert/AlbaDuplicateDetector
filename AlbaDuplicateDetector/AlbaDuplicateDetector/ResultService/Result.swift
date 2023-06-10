//
//  Result.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 24.05.2023.
//

import Foundation

struct Result: Encodable {

    let fileNames: [String]
    let fieldNumbers: [Int]
    let types: [DuplicateType]

    enum DuplicateType: String, Encodable {
        case field
        case `func`
        case `class`
    }
}
