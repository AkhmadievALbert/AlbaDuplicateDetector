//
//  ASTBuilder.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 19.03.2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser
import SwiftSyntaxBuilder


class MySyntaxRewriter: SyntaxRewriter {

    var astClasses: [ASTClass] = []
    var currentClass: ASTClass?
    private let converter: SourceLocationConverter

    init(converter: SourceLocationConverter) {
        self.converter = converter
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        currentClass = ASTClass()
        currentClass?.name = node.identifier.text
        astClasses.append(currentClass!)

        return super.visit(node)
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        currentClass = ASTClass()
        currentClass?.name = node.identifier.text
        astClasses.append(currentClass!)

        return super.visit(node)
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        guard
            let currentClass,
            let name = node.bindings.first?.pattern.description.trimmingCharacters(in: .whitespacesAndNewlines),
            let type = node.bindings.first?.typeAnnotation?.description.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return super.visit(node)
        }

        let astVar = ASTVar(
            name: name,
            fieldNumber: 0, //node.startLocation(converter: converter).line ?? 0,
            type: type
        )
        currentClass.astVars.append(astVar)
        return super.visit(node)
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        guard
            let currentClass
        else {
            return super.visit(node)
        }
        let astFunc = ASTFunc(
            name: node.signature.input.description,
            fieldNumber: 0, //node.startLocation(converter: converter).line ?? 0,
            returnType: node.signature.output?.description ?? "Void",
            funcs: [])
        currentClass.astFuncs.append(astFunc)
        return super.visit(node)
    }
}

class FuncVisitor: SyntaxRewriter {

    private let classFields: [ASTVar]

    var vars: [ASTVar : String] = [:]

    init(classFields: [ASTVar]) {
        self.classFields = classFields
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        guard
            let name = node.bindings.first?.pattern.description,
            let type = node.bindings.first?.typeAnnotation?.description
        else {
            return super.visit(node)
        }
        print(name)
        print(type)
        return super.visit(node)
    }
}

final class ASTBuilder {
    /// Принимает массив с путями до файлов и строит на основе них общее сжатое AST дерево
    /// возвращает самую верхнюю ноду
    func buildASTForFiles(with paths: [String], for groupName: String = "Default") -> [ASTClass] {

        var astClasses: [ASTClass] = []

        for path in paths {
            let fileURL = URL(fileURLWithPath: path)

            let sourceFile = try! SyntaxParser.parse(fileURL)

            let converter = SourceLocationConverter(file: path, tree: sourceFile)

            let visitor = MySyntaxRewriter(converter: converter)
            print("ALBA:")
            _ = visitor.visit(sourceFile)
            print(visitor.astClasses)
            visitor.astClasses.forEach { astClass in
                astClasses.append(astClass)
                print(astClass.astVars)
                print(astClass.astFuncs)
            }
        }

        return astClasses
    }
}
