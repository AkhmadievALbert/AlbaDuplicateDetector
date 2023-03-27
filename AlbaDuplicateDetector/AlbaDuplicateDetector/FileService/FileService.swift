//
//  FileService.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 19.03.2023.
//

import Foundation

final class FileService {

    func getFileNames(containing names: [String], inDirectory directory: String) -> [String: [String]] {
        let fileManager = FileManager.default
        var filesDict = [String: [String]]()

        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory)
            for file in files {
                var isDirectory: ObjCBool = false
                let path = "\(directory)/\(file)"
                fileManager.fileExists(atPath: path, isDirectory: &isDirectory)

                if isDirectory.boolValue {
                    let nestedFiles = getFileNames(containing: names, inDirectory: path)
                    for (name, fileList) in nestedFiles {
                        if let existingList = filesDict[name] {
                            filesDict[name] = existingList + fileList
                        } else {
                            filesDict[name] = fileList
                        }
                    }
                } else {
                    for name in names {
                        if file.contains(name) {
                            let fullPath = "\(directory)/\(file)"
                            if let fileList = filesDict[name] {
                                filesDict[name] = fileList + [fullPath]
                            } else {
                                filesDict[name] = [fullPath]
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }

        return filesDict
    }
}
