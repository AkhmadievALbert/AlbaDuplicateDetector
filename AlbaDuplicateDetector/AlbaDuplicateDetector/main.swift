//
//  main.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 29.01.2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser

let fileService = FileService()
let resultService = ResultService()
let filesDict = fileService.getFileNames(containing: ConfigRepository.shared.fileGroups, inDirectory: ConfigRepository.shared.projectPath)
print(filesDict)

let astBuilder = ASTBuilder()
var astClasses: [ASTClass] = []

for (key, filePaths) in filesDict {
    astClasses = astBuilder.buildASTForFiles(with: filePaths, for: key)
    print("ALBAaaa")
    print(astClasses)
}

let tupleCounts = astClasses.reduce(into: [:]) { counts, astClass in
    counts[ASTClassStruct(astVars: astClass.astVars.map { $0 }, astFuncs: astClass.astFuncs.map { $0 }), default: 0] += 1
}

// Используйте словарь для фильтрации элементов, которые встречаются больше одного раза
let duplicates = astClasses.filter { tupleCounts[ASTClassStruct(astVars: $0.astVars.map { $0 }, astFuncs: $0.astFuncs.map { $0 }), default: 0] > 1 }

// Распечатайте найденные дубликаты
print("Найдены дубликаты:")
duplicates.forEach {
    var type: Result.DuplicateType?
    switch $0 {
    case $0 as ASTClass:
        type = .class
    default:
        type = nil
    }
    var types = [Result.DuplicateType]()
    type.map { types.append($0) }
    resultService.writeResult(directory: ConfigRepository.shared.projectPath, results: [
        .init(fileNames: [$0.name],
              fieldNumbers: [$0.fieldNumber],
              types: types)
    ])
    print($0.name)
}


if ConfigRepository.shared.isSaveByTree {
    fileService.saveASTAsFile(inDirectory: ConfigRepository.shared.projectPath, ast: astClasses)
}
