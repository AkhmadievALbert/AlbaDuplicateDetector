//
//  main.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 29.01.2023.
//

import AST
import Parser
import Source
import Foundation
import SwiftSyntax
import SwiftSyntaxParser

private let dict = "/Users/a.akhmadiev/Developer/diplom/CodeExample/CodeExample"

let fileService = FileService()
let filesDict = fileService.getFileNames(containing: ConfigRepository.shared.fileGroups, inDirectory: ConfigRepository.shared.projectPath)
print(filesDict)

let astBuilder = ASTBuilder()
var astClasses: [ASTClass] = []

for (key, filePaths) in filesDict {
    astClasses = astBuilder.buildASTForFiles(with: filePaths, for: key)
    print(astClasses)
}

let tupleCounts = astClasses.reduce(into: [:]) { counts, astClass in
    counts[ASTClassStruct(astVars: astClass.astVars, astFuncs: astClass.astFuncs), default: 0] += 1
}

// Используйте словарь для фильтрации элементов, которые встречаются больше одного раза
let duplicates = astClasses.filter { tupleCounts[ASTClassStruct(astVars: $0.astVars, astFuncs: $0.astFuncs), default: 0] > 1 }

// Распечатайте найденные дубликаты
print("Найдены дубликаты:")
duplicates.forEach { print($0.name) }
