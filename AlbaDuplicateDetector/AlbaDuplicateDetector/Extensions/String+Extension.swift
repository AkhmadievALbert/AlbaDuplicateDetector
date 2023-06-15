//
//  String+Extension.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 30.01.2023.
//

import Foundation

private let swiftKeywords = Set([
    "let", "return", "func", "var", "if", "public", "as", "else", "in", "import",
    "class", "try", "guard", "case", "for", "init", "extension", "private", "static",
    "fileprivate", "internal", "switch", "do", "catch", "enum", "struct", "throws",
    "throw", "typealias", "where", "break", "deinit", "subscript", "is", "while",
    "associatedtype", "inout", "continue", "operator", "repeat", "rethrows",
    "default", "protocol", "defer", "await", /* Any, Self, self, super, nil, true, false */
])

private let swiftPrefixKeywords = Set([
    "let", "return", "func", "var", "if", "public", "as", "else", "in", "import",
    "class", "try", "guard", "case", "for", "init", "extension", "private", "static",
    "fileprivate", "internal", "switch", "do", "catch", "enum", "struct", "throws",
    "throw", "typealias", "where", "break", "deinit", "subscript", "is", "while",
    "associatedtype", "inout", "continue", "operator", "repeat", "rethrows",
    "default", "protocol", "defer", "await", /* Any, Self, self, super, nil, true, false */
])

private let skippingKeywords: Set<String> = ["private", "public", "static", "open", "private static", "public static", "open static"]

extension String {

    /// Return true exist matching prefix if any
    /// Return false otherwise
    func hasPrefix(prefixes: Set<String>) -> Bool {
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        for `prefix` in prefixes {
            if trimmedString.hasPrefix(`prefix`) { return true }
        }
        return false
    }

    /// Return matching prefix if any
    /// Return nil otherwise
    func getPrefix(prefixes: Set<String>) -> String? {
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        for `prefix` in prefixes {
            if trimmedString.hasPrefix(`prefix`) { return `prefix` }
        }
        return nil
    }

    /// Return matching prefix without beginning keywords if any
    /// Return nil otherwise
    func getPrefixWithoutSkippingKeywords(prefixes: Set<String>) -> String? {
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        for `prefix` in prefixes {
            if trimmedString.hasPrefix(`prefix`) { return `prefix` }
        }
        return nil
    }
}
