//
//  helper.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation
import Sangeuinterpreter

func runScript() {
    do {
        try Sangeuinterpreter.runFile(path: try getScriptFilePath())
    } catch {
        exit(64)
    }
}

func runPrompt() {
    Sangeuinterpreter.runPrompt()
}

func getEffectiveArguments() -> [String] {
    return Array(CommandLine.arguments.dropFirst())
}

func getNumberOfEffectiveArguments() -> Int {
    return getEffectiveArguments().count
}

func isInvalidNumberOfArguments() -> Bool {
    return getNumberOfEffectiveArguments() > 1
}

func isValidNumberOfArgumentsForRunScript() -> Bool {
    return getNumberOfEffectiveArguments() == 1
}

func getScriptFilePath() throws -> String {
    guard let path = getEffectiveArguments().first else {
        throw ArgumentException.cannotFindScriptFilePath
    }
    
    return path
}
