//
//  FunctionCallable.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

final class FunctionCallable {
    private let declaration: Stmt.Function
    private let closure: Environment
    private let isInitializer: Bool
    
    init(declaration: Stmt.Function, closure: Environment, isInitializer: Bool) {
        self.declaration = declaration
        self.closure = closure
        self.isInitializer = isInitializer
    }
    
    func bind(instance: Instance) -> FunctionCallable {
        let environment = Environment(enclosing: self.closure)
        environment.define(name: "this", value: instance)
        
        return .init(declaration: self.declaration, closure: environment, isInitializer: self.isInitializer)
    }
}

extension FunctionCallable: Callable {
    var description: String {
        return "<fn " + self.declaration.name.lexeme + ">"
    }
    
    var arity: Int { return
        self.declaration.parameters.count
    }
    
    func call(interpreter: Interpreter, arguments: [Any?]) throws -> Any? {
        let environment = Environment(enclosing: self.closure)
        
        for (index, parameter) in self.declaration.parameters.enumerated() {
            environment.define(name: parameter.lexeme, value: arguments[index])
        }
        
        do {
            try interpreter.execute(block: declaration.body, environment: environment)
        } catch {
            if let returnException = error as? Return {
                if self.isInitializer {
                    return try self.closure.get(at: .zero, name: "this")
                }
                
                return returnException.value
            }
        }
        
        if self.isInitializer {
            return try self.closure.get(at: .zero, name: "this")
        }
        
        return nil
    }
}
