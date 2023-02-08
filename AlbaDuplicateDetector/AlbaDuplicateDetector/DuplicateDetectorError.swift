//
//  DuplicateDetectorError.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 04.02.2023.
//

import Foundation

enum DuplicateDetectorError: Error {
    case compilationError(file: String, lineNumber: Int)
    case unknown(description: String)
}
