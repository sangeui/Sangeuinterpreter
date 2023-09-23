//
//  helper.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

func directory() -> String {
    return URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sangeuinterpreter")
        .absoluteString
}

func type(key: String, values: String...) -> String {
    return key + ":" + values.joined(separator: ",")
}
