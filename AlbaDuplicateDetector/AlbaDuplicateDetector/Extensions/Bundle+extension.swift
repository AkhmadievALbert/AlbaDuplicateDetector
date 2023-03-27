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
        // swiftlint:disable force_try
        let data = try! Data(contentsOf: url)
        // swiftlint:disable force_try
        return data
    }
}
