//
//  AST.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 08.02.2023.
//

import Foundation
import AST
import Parser
import Source

private let file = "/Users/a.akhmadiev/Developer/diplom/AlbaDuplicateDetector/AlbaDuplicateDetector/AlbaDuplicateDetector/Example/Example.swift"

class MyVisitor : AST.ASTVisitor {
    func visit(_ ifStmt: IfStatement) throws -> Bool {
        print(ifStmt)

        return true
    }
}
//
//func doThis() {
//    do {
//        let sourceFile = try SourceReader.read(at: file)
//        let parser = Parser(source: sourceFile)
//        let topLevelDecl = try parser.parse()
//
//        let a = try myVisitor.traverse(topLevelDecl)
//        print(a)
//        print("ALBA")
//    } catch {
//        print(error.localizedDescription)
//    }
//
//}
