//
//  Error+.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

class Return: Error {
    let value: Any?
    
    init(value: Any?) {
        self.value = value
    }
}

enum RuntimeError: Error {
    case unknown(Token, String)
    case message(String)
}
