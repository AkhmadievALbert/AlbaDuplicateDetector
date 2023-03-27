//
//  ASTNode.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 19.03.2023.
//

import Foundation

struct ASTNode: Hashable {
    let astClass: ASTClass
    var children: [ASTNode]
}

struct ASTClassStruct: Hashable {
    let astVars: [ASTVar]
    let astFuncs: [ASTFunc]
}

class ASTClass: Hashable {
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

struct ASTVar: Hashable {
    let name: String
    let fieldNumber: Int
    let type: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

struct ASTFunc: Hashable {
    let name: String
    let fieldNumber: Int
    var returnType: String = "Void"
    var fieldMap: [ASTVar : String] = [:]

    func hash(into hasher: inout Hasher) {
        hasher.combine(returnType)
        hasher.combine(fieldMap)
    }
}

enum ASTNodeType {
    case classType
    case funcType
    case protocolType
    case varType
    case structType
}
