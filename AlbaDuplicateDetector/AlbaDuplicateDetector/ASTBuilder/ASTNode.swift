//
//  ASTNode.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 19.03.2023.
//

import Foundation

/// Основная нода для всего дерева
struct ASTNode: Hashable, Codable {
    let astClass: ASTClass
    var children: [ASTNode]
}

/// Нужно для сравнения (для поиска дублирования)
struct ASTClassStruct: Hashable, Codable {
    let astVars: [ASTVar]
    let astFuncs: [ASTFunc]
}

/// Нода описывающая класс
class ASTClass: Hashable, Codable {
    var name: String = ""
    let fieldNumber: Int = 0
    var astVars: [ASTVar] = []
    var astFuncs: [ASTFunc] = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(astFuncs)
        hasher.combine(astVars)
    }

    static func == (lhs: ASTClass, rhs: ASTClass) -> Bool {
        lhs.astFuncs == rhs.astFuncs &&
        lhs.astVars == lhs.astVars
    }
}

/// Нода описывающая переменную
struct ASTVar: Hashable, Codable {
    let name: String
    let fieldNumber: Int
    let type: String
    var fieldMap: [String] = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(fieldMap)
    }
}

/// Нода описывающая функцию
struct ASTFunc: Hashable, Codable {
    let name: String
    let fieldNumber: Int
    var returnType: String = "Void"
    var funcs: [ASTFunc]

    func hash(into hasher: inout Hasher) {
        hasher.combine(returnType)
    }
}

enum ASTNodeType: Codable {
    case classType
    case funcType
    case protocolType
    case varType
    case structType
}
