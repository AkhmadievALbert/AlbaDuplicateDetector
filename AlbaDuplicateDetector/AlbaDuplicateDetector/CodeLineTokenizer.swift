//
//  CodeLineTokenizer.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 04.02.2023.
//

import Foundation

class CodeLineTokenizer {
    private var lines: [String]
    private var currentIndex = 0

    init(code: String) {
        self.lines = code.components(separatedBy: .newlines)
    }

    func nextToken() -> String? {
        if lines.isEmpty { return nil }
        return lines.removeFirst()
    }
}
