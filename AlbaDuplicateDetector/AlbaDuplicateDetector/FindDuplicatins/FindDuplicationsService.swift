//
//  FindDuplicationsService.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 13.06.2023.
//

import Foundation

final class FindDuplicationsService {

    func findDuplications(astClasses: [ASTClass]) -> [Result] {
        let results: [Result]
        var classHashMap: [Int: [ASTClass]] = [:]
        var funcHashMap: [Int: [ASTFunc]] = [:]
        var fieldHashMap: [Int: [ASTVar]] = [:]

        astClasses.forEach { astClass in
            
        }
    }
}
