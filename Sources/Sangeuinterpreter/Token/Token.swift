//
//  Token.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

class Token {
    let type: Token.`Type`
    let lexeme: String
    let literal: Any?
    let line: Int
    
    init(type: Token.`Type`, lexeme: String, literal: Any?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
}
