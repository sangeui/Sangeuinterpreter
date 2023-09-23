//
//  ClassCallable.swift
//  
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

final class ClassCallable {
    private let name: String
    private let methods: [String: FunctionCallable]
    
    init(name: String, methods: [String: FunctionCallable]) {
        self.name = name
        self.methods = methods
    }
    
    func find(method name: String) -> FunctionCallable? {
        return self.methods[name]
    }
}

extension ClassCallable: CustomStringConvertible {
    var description: String {
        return self.name
    }
}

extension ClassCallable: Callable {
    var arity: Int {
        if let initializer = self.find(method: "init") {
            return initializer.arity
        }
        
        return .zero
    }
    
    func call(interpreter: Interpreter, arguments: [Any?]) throws -> Any? {
        let instance = Instance(class: self)
        
        if let initializer = self.find(method: "init") {
            _ = try initializer.bind(instance: instance).call(interpreter: interpreter, arguments: arguments)
        }
        
        return instance
    }
}

// MARK: Instance
final class Instance {
    private let `class`: ClassCallable
    private var fields: [String: Any?] = .init()
    
    init(`class`: ClassCallable) {
        self.`class` = `class`
    }
    
    func `get`(name: Token) throws -> Any? {
        if self.fields.contains(where: { $0.key == name.lexeme }) {
            return self.fields[name.lexeme] as Any?
        }
        
        if let method = self.`class`.find(method: name.lexeme) {
            return method.bind(instance: self)
        }
        
        throw RuntimeError.unknown(name, "Undefined property '\(name.lexeme)'.")
    }
    
    func `set`(name: Token, value: Any?) {
        self.fields.updateValue(value, forKey: name.lexeme)
    }
}

extension Instance: CustomStringConvertible {
    var description: String {
        return "\(self.`class`.description) instance"
    }
}
