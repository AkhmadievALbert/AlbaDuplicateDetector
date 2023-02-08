//
//  CodeDuplicationFinder.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 04.02.2023.
//

import Foundation

private let skippingKeywords: Set<String> = ["private", "public", "static", "open", "final"]

class CodeDuplicationFinder {

    /// Return map [filename: Tokens], where Tokens is tokens tree from classes in a file
    func loadFiles(at path: String) throws -> [String: [Class]] {
        let fileManager = FileManager.default
        let directoryContents = try fileManager.contentsOfDirectory(atPath: path)
        var fileContents: [String: [Class]] = [:]

        for file in directoryContents {
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(file)
            let code = try String(contentsOf: fileURL, encoding: .utf8)
            let classes = ClassParser(code: code).extractClassesAndMembers(from: code)

            fileContents[file] = classes
        }
        return fileContents
    }

    private func getClasses(fileURL: URL, code: String) throws -> [Class] {
        let lines = code.split(whereSeparator: \.isNewline)
        var classes: [Class] = []
        try lines.forEach { line in
            let codeLine = String(line)
            let tokenizer = CodeLineTokenizer(code: codeLine)
            var tokenClass = Class(name: "")

            while let token = tokenizer.nextToken() {
                if skippingKeywords.contains(token) { continue }
                if token == "func" {
                    guard let funcName = tokenizer.nextToken() else {
                        throw DuplicateDetectorError.compilationError(file: fileURL.lastPathComponent, lineNumber: 0) // TODO: FIX line number
                    }
                    let funcToken = FuncToken(
                        isPrivate: true,
                        name: funcName,
                        parameterTypes: [],
                        returnTypes: []
                    )
                }
            }
            classes.append(tokenClass)
        }
        return classes
    }
}

