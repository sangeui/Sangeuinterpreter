//
//  Environment.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

class Environment {
    private(set) var enclosing: Environment?
    private var values: Dictionary<String, Any?> = .init()
    
    init(enclosing: Environment? = nil) {
        self.enclosing = enclosing

    }
    
    func define(name: String, value: Any?) {
        self.values.updateValue(value, forKey: name)
    }
    
    func assign(token: Token, value: Any?) throws {
        if self.values.index(forKey: token.lexeme) == nil {
            if let enclosing {
                try enclosing.assign(token: token, value: value)
            } else {
                throw RuntimeError.unknown(token, "Undefined variable '\(token.lexeme)'.")
            }
        } else {
            self.values.updateValue(value, forKey: token.lexeme)
        }
    }
    
    func assign(at distance: Int, token: Token, value: Any?) throws {
        try self.ancestor(distance: distance).values.updateValue(value, forKey: token.lexeme)
    }
    
    func get(token: Token) throws -> Any? {
        if let index = self.values.index(forKey: token.lexeme) {
            return self.values[index].value
        }
        
        if let enclosing {
            return try enclosing.get(token: token)
        }
        
        throw RuntimeError.unknown(token, "Undefined variable '\(token.lexeme)'.")
    }
    
    func get(at distance: Int, name: String) throws -> Any? {
        return try self.ancestor(distance: distance).values[name] as Any?
    }
}

private extension Environment {
    func ancestor(distance: Int) throws -> Environment {
        var environment: Environment = self
        
        for _ in 0..<distance {
            guard let enclosing = environment.enclosing else {
                throw RuntimeError.message("Can't find any scope")
            }
            
            environment = enclosing
        }
        
        return environment
    }
}
