//
//  AlbaDuplicationDetectorMain.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 16.06.2023.
//

import Foundation
import SwiftSyntax

final class AlbaDuplicationDetectorMain {

    let fileService = FileService()
    let resultService = ResultService()
    var findDuplicationsService: FindDuplicationsService!

    func run() {
        let filesDict = fileService.getFileNames(containing: ConfigRepository.shared.fileGroups, inDirectory: ConfigRepository.shared.projectPath)
        print(filesDict)

        let astBuilder = ASTBuilder()
        var astClasses: [ASTClass] = []

        for (key, filePaths) in filesDict {
            astClasses = astBuilder.buildASTForFiles(with: filePaths, for: key)
            print(astClasses)
        }

        findDuplicationsService = FindDuplicationsService(astClasses: astClasses)
        let results = findDuplicationsService.findDuplications()
        fileService.saveResultsFile(inDirectory: ConfigRepository.shared.projectPath, results: results)
        print(results)

        if ConfigRepository.shared.isSaveByTree {
            fileService.saveASTAsFile(inDirectory: ConfigRepository.shared.projectPath, ast: astClasses)
        }
    }
}
