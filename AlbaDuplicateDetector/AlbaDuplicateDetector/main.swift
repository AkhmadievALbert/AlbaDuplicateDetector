//
//  main.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 29.01.2023.
//

import Foundation

private let file = "/Users/a.akhmadiev/Developer/diplom/AlbaDuplicateDetector/AlbaDuplicateDetector/AlbaDuplicateDetector/Example"

let cdf = CodeDuplicationFinder()

do {
    try print(cdf.loadFiles(at: file))
} catch {
    print(error)
}
