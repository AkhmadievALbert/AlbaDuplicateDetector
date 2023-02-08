//
//  TokenType.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 29.01.2023.
//

import Foundation

struct ClassesTokens {
    var tokens: [TokenType]
}

enum TokenType: Hashable {
    case field(FieldToken)
    case `func`(FuncToken)
    case change(ChangedFieldToken)
}

struct FieldToken: Hashable {
    let isPrivate: Bool
    let name: String
    let types: [String]
    let properties: [String: String]
}

struct FuncToken: Hashable {
    let isPrivate: Bool
    let name: String
    let parameterTypes: [String]
    let returnTypes: [String]
}

struct ChangedFieldToken: Hashable {
    let funcToken: FuncToken
    let properties: [FieldToken: [String: String]]
}
