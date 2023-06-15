//
//  ClassParser.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 05.02.2023.
//

import Foundation

struct Class {
    let name: String
    var fields: [Field] = []
    var functions: [Function] = []
}

struct Function {
    let name: String
    var arguments: [String] = []
    var fields: [String: String]
}

struct Field {
    let name: String
    let types: [String]
}

class ClassParser {

    private let tokenizer: CodeLineTokenizer

    init(code: String) {
        self.tokenizer = CodeLineTokenizer(code: code)
    }

    func extractClassesAndMembers(from contents: String) -> [Class] {
        let lines = contents.components(separatedBy: .newlines)
        var classes: [Class] = []

        var currentClass: Class?
        var currentFunction: Function?

        for line in lines {
            if line.contains("class") {
                let components = line.components(separatedBy: "class")
                if components.count > 1 {
                    let classDeclaration = components[1]
                    let className = classDeclaration.components(separatedBy: "{").first?.trimmingCharacters(in: .whitespaces)
                    if let className = className {
                        currentClass = Class(name: className)
                        classes.append(currentClass!)
                    }
                }
            } else if line.contains("func") {
                let components = line.components(separatedBy: "func")
                if components.count > 1 {
                    let functionDeclaration = components[1]
                    let functionName = functionDeclaration.components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces)
                    if let functionName = functionName, var `class` = currentClass {
                        currentFunction = Function(name: functionName, fields: [:])
                        `class`.functions.append(currentFunction!)
                    }
                }
            } else if line.contains("var") || line.contains("let") {
                let components = line.components(separatedBy: " ")
                if components.count > 2 {
                    let fieldDeclaration = components[2]
                    let fieldName = fieldDeclaration.components(separatedBy: ":").first?.trimmingCharacters(in: .whitespaces)
                    if let fieldName = fieldName {
                        if var function = currentFunction {
                            function.fields[fieldName] = fieldName
                        } else if var `class` = currentClass {
                            `class`.fields.append(Field(name: fieldName, types: []))
                        }
                    }
                }
            }
        }

        return classes
    }
}
