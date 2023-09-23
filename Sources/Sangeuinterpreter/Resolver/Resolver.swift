//
//  Resolver.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

final class Resolver {
    private let interpreter: Interpreter
    private var scopes: [Dictionary<String, Bool>] = .init()
    private var currentFunction: FunctionType = .NONE
    private var currentClass: ClassType = .NONE
    
    init(interpreter: Interpreter) {
        self.interpreter = interpreter
    }
    
    func resolve(statements: [Stmt]) {
        do {
            try statements.forEach(self.resolve(statement:))
        } catch {
            
        }
    }
}

extension Resolver: StmtVisitorProtocol {
    typealias StmtVisitorProtocolReturnType = Void
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> Void {
        self.beginScope()
        self.resolve(statements: stmt.statements)
        self.endScope()
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> Void {
        let enclosingClass = self.currentClass
        self.currentClass = .CLASS
        
        self.declare(token: stmt.name)
        
        for method in stmt.methods {
            try self.resolve(function: method, type: .METHOD)
        }
        
        self.define(token: stmt.name)
        
        self.beginScope()
        self.scopes[self.scopes.count - 1].updateValue(true, forKey: "this")
        self.endScope()
        
        self.currentClass = enclosingClass
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> Void {
        self.declare(token: stmt.name)
        
        if let initializer = stmt.initializer {
            try self.resolve(expression: initializer)
        }
        
        self.define(token: stmt.name)
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> Void {
        self.declare(token: stmt.name)
        self.define(token: stmt.name)
        try self.resolve(function: stmt, type: self.currentFunction)
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> Void {
        try self.resolve(expression: stmt.expression)
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> Void {
        try self.resolve(expression: stmt.expression)
        try self.resolve(statement: stmt.thenBranch)
        
        if let elseBranch = stmt.elseBranch {
            try self.resolve(statement: elseBranch)
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> Void {
        try self.resolve(expression: stmt.expression)
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> Void {
        if self.currentFunction == .NONE {
            Sangeuinterpreter.error(token: stmt.keyword, message: "Can't return from top-level code.")
            return
        }
        
        guard let value = stmt.value else {
            return
        }
        
        try self.resolve(expression: value)
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> Void {
        try self.resolve(expression: stmt.condition)
        try self.resolve(statement: stmt.body)
    }
}

extension Resolver: ExprVisitorProtocol {
    typealias ExprVisitorProtocolReturnType = Void
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> Void {
        if isScopesNotEmpty, self.scopes[self.scopes.count - 1][expr.name.lexeme] == false {
            Sangeuinterpreter.error(token: expr.name, message: "Can't read local variable in its own initializer.")
            
            return
        }
        
        self.resolve(local: expr.name, expression: expr)
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> Void {
        try self.resolve(expression: expr.value)
        self.resolve(local: expr.name, expression: expr)
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> Void {
        try self.resolve(expression: expr.left)
        try self.resolve(expression: expr.right)
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> Void {
        try self.resolve(expression: expr.callee)
        
        for argument in expr.arguments {
            try self.resolve(expression: argument)
        }
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> Void {
        try self.resolve(expression: expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> Void {
        
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> Void {
        try self.resolve(expression: expr.left)
        try self.resolve(expression: expr.right)
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> Void {
        try self.resolve(expression: expr.right)
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> Void {
        try self.resolve(expression: expr.object)
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> Void {
        try self.resolve(expression: expr.value)
        try self.resolve(expression: expr.object)
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> Void {
        if self.currentClass == .NONE {
            Sangeuinterpreter.error(token: expr.keyword, message: "Can't use 'this' outside of a class.")
        }
        
        self.resolve(local: expr.keyword, expression: expr)
    }
}

private extension Resolver {
    var isScopesNotEmpty: Bool {
        return self.scopes.isEmpty == false
    }
    
    func declare(token: Token) {
        guard isScopesNotEmpty else { return }
        
        if self.scopes[self.scopes.count - 1].contains(where: { $0.key == token.lexeme }) {
            Sangeuinterpreter.error(token: token, message: "Already a variable with this name in this scope.")
        }
        
        self.scopes[self.scopes.count - 1].updateValue(false, forKey: token.lexeme)
    }
    
    func define(token: Token) {
        guard isScopesNotEmpty else { return }
        
        self.scopes[self.scopes.count - 1].updateValue(true, forKey: token.lexeme)
    }
}

private extension Resolver {
    func resolve(statement: Stmt) throws {
        try statement.accept(visitor: self)
    }
    
    func resolve(expression: Expr) throws {
        try expression.accept(visitor: self)
    }
    
    func resolve(local token: Token, expression: Expr) {
        for index in stride(from: self.scopes.count - 1, through: .zero, by: -1) {
            if self.scopes[index].contains(where: { $0.key == token.lexeme }) {
                self.interpreter.resolve(expression: expression, depth: self.scopes.count - index - 1)
            }
        }
    }
    
    func resolve(function: Stmt.Function, type: FunctionType) throws {
        let enclosingFunction = self.currentFunction
        self.currentFunction = type
        
        self.beginScope()
        
        function.parameters.forEach({ parameter in
            self.declare(token: parameter)
            self.define(token: parameter)
        })
        
        self.resolve(statements: function.body)
        self.endScope()
        
        self.currentFunction = enclosingFunction
    }
}

private extension Resolver {
    func beginScope() {
        self.scopes.append(.init())
    }
    
    func endScope() {
        _ = self.scopes.popLast()
    }
}
