//
//  main.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 29.01.2023.
//

import Foundation

if CommandLine.arguments.count == 2 && CommandLine.arguments[1] == "run" {
    let main = AlbaDuplicationDetectorMain()
    main.run()
}
