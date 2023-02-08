//
//  Sets.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 08.02.2023.
//

import Foundation

private let packagePrefixes: Set<String> = ["private", "public", "internal", "open"]
private let changeablePrefixes: Set<String> = ["final", "static"]
private let funcPrefixesSet: Set<String> = ["func"]
private let fieldPrefixesSet: Set<String> = ["var", "let"]
