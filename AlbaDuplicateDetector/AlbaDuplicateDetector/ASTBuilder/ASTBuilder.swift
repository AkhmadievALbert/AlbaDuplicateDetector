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

    var currentClassIndex = -1
    var astClasses: [ASTClass] = []
    private let converter: SourceLocationConverter

    init(converter: SourceLocationConverter) {
        self.converter = converter
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        currentClassIndex += 1
        let currentClass = ASTClass(name: node.identifier.text, fieldNumber: node.startLocation(converter: converter).line ?? 0)
        astClasses.append(currentClass)

        return super.visit(node)
    }

    override func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        currentClassIndex += 1
        let currentClass = ASTClass(name: node.identifier.text, fieldNumber: node.startLocation(converter: converter).line ?? 0)
        astClasses.append(currentClass)

        return super.visit(node)
    }

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        guard
            let name = node.bindings.first?.pattern.description.trimmingCharacters(in: .whitespacesAndNewlines),
            let type = node.bindings.first?.typeAnnotation?.description.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return super.visit(node)
        }

        let astVar = ASTVar(
            name: name,
            fieldNumber: node.startLocation(converter: converter).line ?? 0,
            type: type
        )
        var currentClass = astClasses[currentClassIndex]
        currentClass.astVars.insert(astVar)
        astClasses[currentClassIndex] = currentClass
        return super.visit(node)
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        var currentClass = astClasses[currentClassIndex]
        let astFunc = ASTFunc(
            name: node.identifier.text,
            fieldNumber: node.startLocation(converter: converter).line ?? 0,
            returnType: node.signature.output?.description ?? "Void",
            funcs: []
        )

        node.body?.statements.forEach { statement in
            var astVar: ASTVar?
            if let functionCallExprSyntax = FunctionCallExprSyntax(statement.item) {

                if let calledExpression = MemberAccessExprSyntax(functionCallExprSyntax.calledExpression._syntaxNode) {

                    if let base = calledExpression.base {
                        if let superSyntax = SuperRefExprSyntax(base._syntaxNode) { return }
                        if let identifierExprSyntax = IdentifierExprSyntax(base._syntaxNode) {
                            let name = identifierExprSyntax.identifier.text
                            if let firstLet = currentClass.astVars.first(where: { $0.name == name }) {
                                astVar = firstLet
                            } else {
                                astVar = ASTVar(name: name, fieldNumber: 0, type: name)
                            }
                        }
                        guard var astVar else { return }
                        let funcDidTrigger = calledExpression.name.text
                        astVar.funcsDidTrigger[funcDidTrigger] = astVar.funcsDidTrigger[funcDidTrigger] ?? 0 + 1
                    }
                }
                print(1)
            } else if let sequenceExprSyntax = SequenceExprSyntax(statement.item) {

                var astVar: ASTVar?
                sequenceExprSyntax.elements.forEach { element in

                    if let exprSyntax = ExprSyntax(element._syntaxNode) {
                        if let base = IdentifierExprSyntax(exprSyntax._syntaxNode) {
                            let letName = base.identifier.text
                            if let firstLet = currentClass.astVars.first(where: { $0.name == letName }) {
                                astVar = firstLet
                            } else {
                                astVar = ASTVar(name: letName, fieldNumber: 0, type: letName)
                            }
                        }
                    }

                }
            }
        }

        currentClass.astFuncs.insert(astFunc)
        astClasses[currentClassIndex] = currentClass
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
