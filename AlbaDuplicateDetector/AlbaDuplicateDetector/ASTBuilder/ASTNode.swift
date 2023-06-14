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
struct ASTClass: Hashable, Codable {
    @NotHashable var name: String
    @NotHashable var fieldNumber: Int
    var astVars: Set<ASTVar> = []
    var astFuncs: Set<ASTFunc> = []
}

/// Нода описывающая переменную
struct ASTVar: Hashable, Codable {
    @NotHashable var name: String
    @NotHashable var fieldNumber: Int
    var type: String
    var fieldsChanged: [String:Int] = [:]
    var funcsDidTrigger: [String:Int] = [] 
}

/// Нода описывающая функцию
struct ASTFunc: Hashable, Codable {
    @NotHashable var name: String
    @NotHashable var fieldNumber: Int
    var returnType: String = "Void"
    var funcs: [ASTFunc]
}
