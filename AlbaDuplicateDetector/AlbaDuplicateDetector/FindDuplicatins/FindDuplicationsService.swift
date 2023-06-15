//
//  FindDuplicationsService.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 13.06.2023.
//

import Foundation

final class FindDuplicationsService {

    var results: [Result] = []
    var classHashMap: [Int: [ASTClass]] = [:]
    var funcHashMap: [Int: [ASTFunc]] = [:]

    private let astClasses: [ASTClass]

    init(astClasses: [ASTClass]) {
        self.astClasses = astClasses
    }

    func findDuplications() -> [Result] {
        astClasses.forEach { astClass in
            var isAdded = false
            for (key, duplicateClasses) in classHashMap {
                if areHashesSimilar(astClass.hashValue, key) {
                    classHashMap[key] = duplicateClasses + [astClass]
                    isAdded = true
                    break
                }
            }
            if !isAdded {
                classHashMap[astClass.hashValue] = [astClass]
            }
            findFuncs(funcs: astClass.astFuncs.map { $0 })
        }
        results = classHashMap.reduce(into: [Result]()) { (partialResult, element) in
            let (_, astClasses) = element
            if astClasses.count > 1 {
                partialResult.append(.init(
                    fileNames: astClasses.compactMap { $0.name },
                    fieldNumbers: astClasses.map { $0.fieldNumber },
                    types: [.class]
                ))
            }
        } + funcHashMap.reduce(into: [Result]()) { (partialResult, element) in
            let (_, astFuncs) = element
            if astFuncs.count > 1 {
                partialResult.append(.init(
                    fileNames: astFuncs.compactMap { $0.name },
                    fieldNumbers: astFuncs.map { $0.fieldNumber },
                    types: [.func]
                ))
            }
        }
        return results
    }

    private func findFuncs(funcs: [ASTFunc]) {
        funcs.forEach { `func` in
            var isAdded = false
            for (key, duplicatedFuncs) in funcHashMap {
                if areHashesSimilar(`func`.hashValue, key) {
                    funcHashMap[key] = duplicatedFuncs + [`func`]
                    isAdded = true
                    break
                }
            }
            if !isAdded {
                funcHashMap[`func`.hashValue] = [`func`]
            }
        }
    }
}
