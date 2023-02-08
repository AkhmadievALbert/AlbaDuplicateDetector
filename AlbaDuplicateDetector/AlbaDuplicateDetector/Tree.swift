//
//  Tree.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 07.02.2023.
//

import SwiftSyntax
import SwiftSyntaxParser


enum NodeType {
    case function(FunctionNode)
    case operative(OperativeNode)
    case variable(VariableNode)
}

struct FunctionNode {
    let name: String
    var childrenNodes: [NodeType]
}

struct OperativeNode {
    let name: String
    var childrenNodes: [NodeType]
}

struct VariableNode {
    let name: String
    var type: [String]
}
