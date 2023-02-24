//
//  TreeNode.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 13.02.2023.
//

import Foundation

class TreeNode {
    var val: String
    var children: [TreeNode]
    init(_ val: String) {
        self.val = val
        self.children = []
    }
}
