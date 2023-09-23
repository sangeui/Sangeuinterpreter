//
//  main.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation
import Sangeuinterpreter

if isInvalidNumberOfArguments() {
    exit(64)
}

if isValidNumberOfArgumentsForRunScript() {
    runScript()
} else {
    runPrompt()
}
