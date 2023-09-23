//
//  Scanner.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

import Foundation

class Scanner {
    private let source: String
    private var tokens: [Token] = .init()
    private var start: Int = .zero
    private var current: Int = .zero
    private var line: Int = 1
    
    init(source: String) {
        self.source = source
    }
    
    func scanTokens() -> [Token] {
        while self.isAtEnd == false {
            self.start = self.current
            self.scanToken()
        }
        
        self.tokens.append(.init(type: .EOF, lexeme: .init(), literal: nil, line: line))
        
        return self.tokens
    }
}

extension Scanner {
    static let keywords: [String: Token.`Type`] = [
        "and": .AND,
        "class": .CLASS,
        "else": .ELSE,
        "false": .FALSE,
        "for": .FOR,
        "fun": .FUN,
        "if": .IF,
        "nil": .NIL,
        "or": .OR,
        "print": .PRINT,
        "return": .RETURN,
        "super": .SUPER,
        "this": .THIS,
        "true": .TRUE,
        "var": .VAR,
        "while": .WHILE
    ]
}

private extension Scanner {
    var isAtEnd: Bool {
        return self.current >= self.source.count
    }
    
    @discardableResult
    func advance() -> Character {
        let character = self.source[self.source.index(self.source.startIndex, offsetBy: current)]
        self.current += 1
        return character
    }
    
    func addToken(type: Token.`Type`) {
        self.addToken(type: type, literal: nil)
    }
    
    func addToken(type: Token.`Type`, literal: Any?) {
        let text = self.source[self.source.index(self.source.startIndex, offsetBy: self.start)..<self.source.index(self.source.startIndex, offsetBy: self.current)]
        
        self.tokens.append(.init(type: type, lexeme: .init(text), literal: literal, line: self.line))
    }
    
    func scanToken() {
        let character = self.advance()
        
        switch character {
        case "(": self.addToken(type: .LEFT_PAREN); break
        case ")": self.addToken(type: .RIGHT_PAREN); break
        case "{": self.addToken(type: .LEFT_BRACE); break
        case "}": self.addToken(type: .RIGHT_BRACE); break
        case ",": self.addToken(type: .COMMA); break
        case ".": self.addToken(type: .DOT); break
        case "-": self.addToken(type: .MINUS); break
        case "+": self.addToken(type: .PLUS); break
        case ";": self.addToken(type: .SEMICOLON); break
        case "*": self.addToken(type: .STAR); break
            
        case "!": self.addToken(type: match("=") ? .BANG_EQUAL : .BANG); break
        case "=": self.addToken(type: match("=") ? .EQUAL_EQUAL : .EQUAL); break
        case "<": self.addToken(type: match("=") ? .LESS_EQUAL : .LESS); break
        case ">": self.addToken(type: match("=") ? .GREATER_EQUAL : .GREATER); break
        case "/":
            if match("/") {
                while peek() != "\n" && !isAtEnd {
                    self.advance()
                }
            } else {
                addToken(type: .SLASH)
            }
        case " ", "\r", "\t": break
        case "\n":
            self.line += 1; break
        case "\"": self.string(); break
        default:
            if self.isDigit(character) {
                self.number()
            } else if self.isAlpha(character) {
                self.identifier()
            } else {
                Sangeuinterpreter.error(line: line, message: "Unexpected character.")
            }
        }
    }
    
    func identifier() {
        while self.isAlphaNumeric(self.peek()) {
            self.advance()
        }
        
        let text = String(self.source[self.source.index(self.source.startIndex, offsetBy: self.start)..<self.source.index(self.source.startIndex, offsetBy: self.current)])
        
        let type = Self.keywords[text] ?? .IDENTIFIER
        
        self.addToken(type: type)
    }
    
    func number() {
        while self.isDigit(self.peek()) {
            self.advance()
        }
        
        if self.peek() == "." && self.isDigit(self.peekNext()) {
            self.advance()
            
            while (self.isDigit(self.peek())) {
                self.advance()
            }
        }
        
        let value = Double(self.source[self.source.index(self.source.startIndex, offsetBy: self.start)..<self.source.index(self.source.startIndex, offsetBy: self.current)])
        addToken(type: .NUMBER, literal: value)
    }
    
    func string() {
        while self.peek() != "\"" && !self.isAtEnd {
            if self.peek() == "\n" {
                self.line += 1
            }
            
            self.advance()
        }
        
        if self.isAtEnd {
            Sangeuinterpreter.error(line: self.line, message: "Unterminated string.")
            return
        }
        
        self.advance()
        
        let value = self.source[self.source.index(self.source.startIndex, offsetBy: self.start + 1)..<self.source.index(self.source.startIndex, offsetBy: self.current - 1)]
        
        self.addToken(type: .STRING, literal: String(value))
    }
    
    func match(_ expected: Character) -> Bool {
        if isAtEnd {
            return false
        }
        
        if source[self.source.index(self.source.startIndex, offsetBy: self.current)] != expected {
            return false
        }
        
        current += 1
        
        return true
    }
    
    func peek() -> Character {
        if isAtEnd {
            return "\0"
        }
        
        return source[self.source.index(self.source.startIndex, offsetBy: self.current)]
    }
    
    func peekNext() -> Character {
        if (self.current + 1 >= source.count) {
            return "\0"
        }
        
        return source[self.source.index(self.source.startIndex, offsetBy: self.current + 1)]
    }
    
    func isAlpha(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
    }
    
    func isAlphaNumeric(_ c: Character) -> Bool {
        return self.isAlpha(c) || self.isDigit(c)
    }
    
    func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }
}
