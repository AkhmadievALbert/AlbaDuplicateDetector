//
//  TreeDuplicateDetector.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 13.02.2023.
//

import Foundation

class TreeDuplicateDetector {
    var count = [String: Int]()
    var ans = [TreeNode]()

    func findDuplicateSubtrees(_ root: TreeNode?) -> [TreeNode] {
        serialize(root)
        return ans
    }

    @discardableResult
    func serialize(_ node: TreeNode?) -> String {
        guard let node = node else { return "#" }
        var childStrings = [String]()
        for child in node.children {
            childStrings.append(serialize(child))
        }
        let curr = hash(val: node.val)
        count[curr, default: 0] += 1
        if count[curr] ?? 0 > 1 {
            ans.append(node)
        }
        return curr
    }
}

func hash(val: String) -> String {
    return val
}
