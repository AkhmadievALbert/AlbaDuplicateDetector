//
//  Bundle+extension.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 19.03.2023.
//

import Foundation

extension Bundle {
    static func json(name: String) -> Data {
        let url = main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return data
    }
}
