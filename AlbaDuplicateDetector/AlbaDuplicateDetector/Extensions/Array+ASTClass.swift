//
//  Array+ASTClass.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 26.03.2023.
//

import Foundation

extension Array where Element == ASTClass {

    func getASTClass(with name: String) -> ASTClass? {
        self.first { $0.name == name }
    }
}
