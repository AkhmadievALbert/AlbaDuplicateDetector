//
//  Config.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 19.03.2023.
//

import Foundation

struct Config: Decodable {
    let projectPath: String
    let fileGroups: [String]
    let isSaveByTree: Bool
}

final class ConfigRepository {
    static let shared = ConfigRepository()

    private lazy var config: Config = {
        let decoder = JSONDecoder()
        let json = try! Data(contentsOf: URL(fileURLWithPath: "../../../../../AlbaDuplicateDetector/Config.json"))
        return try! decoder.decode(Config.self, from: json)
    }()

    lazy var projectPath: String = {
        config.projectPath
    }()

    lazy var isSaveByTree: Bool = {
        config.isSaveByTree
    }()

    lazy var fileGroups: [String] = {
        config.fileGroups
    }()
}
