//
//  Utilities.swift
//  OpenHouse
//
//  Created by Hue Pham.
//

import Foundation

func escapeCSV(_ s: String) -> String {
    if s.contains(",") || s.contains("") || s.contains("\"") {
        return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
    return s
}
