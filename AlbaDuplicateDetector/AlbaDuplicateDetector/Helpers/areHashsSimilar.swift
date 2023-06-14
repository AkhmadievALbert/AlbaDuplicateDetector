//
//  areHashsSimilar.swift
//  AlbaDuplicateDetector
//
//  Created by a.akhmadiev on 11.06.2023.
//

import Foundation

func areHashesSimilar<T: Hashable>(_ hash1: T, _ hash2: T, errorThreshold: Double = 0.05) -> Bool {

    let data1 = withUnsafeBytes(of: hash1.hashValue) { Data($0) }
    let byteArray1 = [UInt8](data1)

    let data2 = withUnsafeBytes(of: hash2.hashValue) { Data($0) }
    let byteArray2 = [UInt8](data2)

    // Проверка, что массивы одинаковой длины
    guard byteArray1.count == byteArray2.count else {
        return false
    }

    let length = byteArray1.count
    let maxErrors = Int(Double(length) * errorThreshold)
    var errors = 0

    // Расчет расстояния Хэминга
    for i in 0..<length {
        if byteArray1[i] != byteArray2[i] {
            errors += 1
            if errors > maxErrors {
                return false
            }
        }
    }

    return true
}
