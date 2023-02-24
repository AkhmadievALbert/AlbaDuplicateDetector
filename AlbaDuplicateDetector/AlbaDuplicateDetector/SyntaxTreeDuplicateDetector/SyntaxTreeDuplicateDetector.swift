//
//  SyntaxTreeDuplicateDetector.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 13.02.2023.
//

import SwiftSyntax

class SyntaxTreeDuplicateDetector {
    var count = [String: Int]()
    var ans = [Syntax]()

    func findDuplicateSubtrees(_ root: Syntax?) -> [Syntax] {
        serialize(root)
        return ans
    }

    @discardableResult
    func serialize(_ node: Syntax?) -> String {
        guard let node = node else { return "#" }
        var childStrings = [String]()
        for child in node.children {
            childStrings.append(serialize(child))
        }
        let curr = "\(node.description)\(childStrings.sorted().joined(separator: ","))"
        count[curr, default: 0] += 1
        if count[curr] == 2 {
            ans.append(node)
        }
        return curr
    }
}
