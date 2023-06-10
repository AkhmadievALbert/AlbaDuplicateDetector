//
//  ResultServiceProtocol.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 24.05.2023.
//

import Foundation

protocol ResultServiceProtocol {
    func writeResult(directory: String, results: [Result])
}

final class ResultService: ResultServiceProtocol {

    func writeResult(directory: String, results: [Result]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(results)
            let path = "\(directory)/result.json"
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            print(error)
        }
    }
}
