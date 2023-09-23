//
//  helper.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

func runScript() {
    do {
        
    } catch {
        exit(64)
    }
}

func runPrompt() {
    
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
