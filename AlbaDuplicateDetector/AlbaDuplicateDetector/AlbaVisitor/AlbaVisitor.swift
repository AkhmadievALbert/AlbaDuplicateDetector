//
//  AlbaVisitor.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 18.03.2023.
//

import AST
import Parser
import Source
import Foundation
import SwiftSyntax
import SwiftSyntaxParser

private let file = "/Users/a.akhmadiev/Developer/diplom/AlbaDuplicateDetector/AlbaDuplicateDetector/AlbaDuplicateDetector/Example/Example.swift"

class ALbaVisitor : ASTVisitor {

    var functions: [FunctionDeclaration] = []
    var duplicates: [(FunctionDeclaration, FunctionDeclaration)] = []

    func visit(_ function: FunctionDeclaration) throws -> Bool {
        // visit this if statement
        functions.append(function)
        return true
    }

    func findFuncClones() {
        for a in 0...functions.count-1 {
            for b in 1...functions.count-1 {
                let aFunc = functions[a]
                let bFunc = functions[b]
                if aFunc.signature.result?.textDescription == bFunc.signature.result?.textDescription {
                    duplicates.append((aFunc, bFunc))
                }
            }
        }
    }
}

func doWithVisitor() {
    do {
        let sourceFile = try SourceReader.read(at: file)
        let parser = Parser(source: sourceFile)

        let myVisitor = ALbaVisitor()
        let topLevelDecl = try parser.parse()
//        try myVisitor.traverse(topLevelDecl)
        myVisitor.findFuncClones()
        print(myVisitor.duplicates)
    } catch {
        // handle errors
    }
}
