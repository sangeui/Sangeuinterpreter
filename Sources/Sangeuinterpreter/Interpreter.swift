//
//  Interpreter.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

public class Interpreter {
    private let globalEnvironment = Interpreter.createStaticGlobalEnvironment
    private var locals = Dictionary<Expr, Int>()
    
    private var environment: Environment
    
    init() {
        self.environment = globalEnvironment
    }
    
    func interpret(expression: Expr) {
        do {
            let value = try self.evaluate(expression: expression)
            
            print(self.stringify(value: value))
        } catch let error as RuntimeError {
            Sangeuinterpreter.error(runtimeError: error)
        } catch {
            Sangeuinterpreter.error(runtimeError: .message(error.localizedDescription))
        }
    }
    
    func interpret(statements: [Stmt]) {
        do {
            for statement in statements {
                try self.execute(statement: statement)
            }
        } catch let error as RuntimeError {
            Sangeuinterpreter.error(runtimeError: error)
        } catch {
            Sangeuinterpreter.error(runtimeError: .message(error.localizedDescription))
        }
    }
    
    private func execute(statement: Stmt) throws {
        try statement.accept(visitor: self)
    }
    
    private func stringify(value: Any?) -> String {
        guard let value else {
            return "nil"
        }
        
        if let value = value as? Double {
            let string = String(value)
            
            return string.hasSuffix(".0") ? .init(string.dropLast(2)) : string
        }
        
        if let value = value as? String {
            return value
        }
        
        return .init(describing: value)
    }
}

extension Interpreter: StmtVisitorProtocol {
    typealias StmtVisitorProtocolReturnType = Void
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> Void {
        try self.execute(block: stmt.statements, environment: .init(enclosing: self.environment))
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> Void {
        self.environment.define(name: stmt.name.lexeme, value: nil)
        
        var methods: [String: FunctionCallable] = .init()
        
        for method in stmt.methods {
            let isInitializer = method.name.lexeme == "init"
            let function = FunctionCallable(declaration: method, closure: self.environment, isInitializer: isInitializer)
            methods.updateValue(function, forKey: method.name.lexeme)
        }
        
        let `class` = ClassCallable(name: stmt.name.lexeme, methods: methods)
        try self.environment.assign(token: stmt.name, value: `class`)
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> Void {
        try self.evaluate(expression: stmt.expression)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> Void {
        let value = try self.evaluate(expression: stmt.expression)
        
        print(self.stringify(value: value))
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> Void {
        var value: Any? = nil
        
        if let expression = stmt.value {
            value = try self.evaluate(expression: expression)
        }
        
        throw Return(value: value)
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> Void {
        var value: Any? = nil
        
        if let initializer = stmt.initializer {
            value = try self.evaluate(expression: initializer)
        }
        
        self.environment.define(name: stmt.name.lexeme, value: value)
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> Void {
        if self.isTruthy(value: try self.evaluate(expression: stmt.expression)) {
            try self.execute(statement: stmt.thenBranch)
        } else if let statement = stmt.elseBranch {
            try self.execute(statement: statement)
        }
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> Void {
        while (isTruthy(value: try self.evaluate(expression: stmt.condition))) {
            try self.execute(statement: stmt.body)
        }
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> Void {
        let function = FunctionCallable(declaration: stmt, closure: self.environment, isInitializer: false)
        
        self.environment.define(name: stmt.name.lexeme, value: function)
    }
    
    func execute(block: [Stmt], environment: Environment) throws {
        let previous = self.environment
        self.environment = environment
        defer {
            self.environment = previous
        }
        
        for statement in block {
            try self.execute(statement: statement)
        }
    }
}

extension Interpreter: ExprVisitorProtocol {
    typealias ExprVisitorProtocolReturnType = Any?
    
    func visitCallExpr(_ expr: Expr.Call) throws -> Any? {
        let callee = try self.evaluate(expression: expr.callee)
        let arguments = try expr.arguments.map({ try self.evaluate(expression: $0)})
        
        guard let callable = callee as? Callable else {
            throw RuntimeError.unknown(expr.paren, "Can only call functions and classes.")
        }
        
        if arguments.count != callable.arity {
            throw RuntimeError.unknown(expr.paren, "Expected \(callable.arity) arguments but got \(arguments.count)")
        }
        
        return try callable.call(interpreter: self, arguments: arguments)
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> Any? {
        let left = try self.evaluate(expression: expr.left)
        
        if expr._operator.type == .OR {
            if self.isTruthy(value: left) {
                return left
            }
        } else {
            if self.isTruthy(value: left) == false {
                return left
            }
        }
        
        return try self.evaluate(expression: expr.right)
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> Any? {
        let value = try self.evaluate(expression: expr.value)
        
        guard let distance = self.locals[expr] else {
            try self.globalEnvironment.assign(token: expr.name, value: value)
            
            return value
        }
        
        try self.environment.assign(at: distance, token: expr.name, value: value)
        
        return value
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> Any? {
        return try self.lookup(variable: expr.name, expression: expr)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> Any? {
        return expr.value
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> Any? {
        return try self.evaluate(expression: expr.expression)
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> Any? {
        let right = try self.evaluate(expression: expr.right)
        
        switch expr._operator.type {
        case .MINUS:
            if let double = right as? Double {
                return -double
            }
            
        case .BANG:
            return !isTruthy(value: right)
            
        default:
            break
        }
        
        // Unreachable.
        return nil
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> Any? {
        let left = try self.evaluate(expression: expr.left)
        let right = try self.evaluate(expression: expr.right)
        
        switch expr._operator.type {
        case .MINUS:
            let (left, right) = try self.convertToDouble(left: left, right: right, operator: expr._operator)
            return left - right
            
        case .SLASH:
            let (left, right) = try self.convertToDouble(left: left, right: right, operator: expr._operator)
            
            return left / right
            
        case .STAR:
            let (left, right) = try self.convertToDouble(left: left, right: right, operator: expr._operator)
            
            return left * right
            
        case .PLUS:
            if let left = left as? Double, let right = right as? Double {
                return left + right
            }
            
            if let left = left as? String, let right = right as? String {
                return left + right
            }
            
        case .GREATER:
            let (left, right) = try self.convertToDouble(left: left, right: right, operator: expr._operator)
            
            return left > right
            
        case .GREATER_EQUAL:
            let (left, right) = try self.convertToDouble(left: left, right: right, operator: expr._operator)
            
            return left >= right
            
        case .LESS:
            let (left, right) = try self.convertToDouble(left: left, right: right, operator: expr._operator)
            
            return left < right
            
        case .LESS_EQUAL:
            let (left, right) = try self.convertToDouble(left: left, right: right, operator: expr._operator)
            
            return left <= right
            
        case .BANG_EQUAL:
            return !self.isEqual(lhs: left, rhs: right)
            
        case .EQUAL_EQUAL:
            return self.isEqual(lhs: left, rhs: right)
            
        default:
            break
        }
        
        // Unreachable.
        return nil
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> Any? {
        guard let object = try self.evaluate(expression: expr.object) as? Instance else {
            throw RuntimeError.unknown(expr.name, "Only instances have properties.")
        }
        
        return try object.get(name: expr.name)
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> Any? {
        guard let object = try self.evaluate(expression: expr.object) as? Instance else {
            throw RuntimeError.unknown(expr.name, "Only instances have fields.")
        }
        
        let value = try self.evaluate(expression: expr.value)
        object.`set`(name: expr.name, value: value)
        
        return value
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> Any? {
        return try self.lookup(variable: expr.keyword, expression: expr)
    }
}

extension Interpreter {
    func resolve(expression: Expr, depth: Int) {
        self.locals.updateValue(depth, forKey: expression)
    }
    
    private func lookup(variable: Token, expression: Expr) throws -> Any? {
        guard let distance = self.locals[expression] else {
            
            return try self.globalEnvironment.get(token: variable)
        }
        
        return try environment.get(at: distance, name: variable.lexeme)
    }
}

private extension Interpreter {
    @discardableResult
    func evaluate(expression: Expr) throws -> Any? {
        try expression.accept(visitor: self)
    }
}

private extension Interpreter {
    func isTruthy(value: Any?) -> Bool {
        if value == nil {
            return false
        }
        
        if let bool = value as? Bool {
            return bool
        }
        
        return true
    }
    
    func isEqual(lhs: Any?, rhs: Any?) -> Bool {
        if lhs == nil && rhs == nil {
            return true
        }
        
        if lhs == nil {
            return false
        }
        
        if let lhs = lhs as? Double, let rhs = rhs as? Double {
            return lhs == rhs
        }
        
        if let lhs = lhs as? String, let rhs = rhs as? String {
            return lhs == rhs
        }
        
        if let lhs = lhs as? Bool, let rhs = rhs as? Bool {
            return lhs == rhs
        }
        
        return false
    }
    
    func convertToDouble(left: Any?, right: Any?, operator: Token) throws -> (Double, Double) {
        let left = try self.convertToDouble(value: left, operator: `operator`)
        let right = try self.convertToDouble(value: right, operator: `operator`)
        
        return (left, right)
    }
    
    func convertToDouble(value: Any?, operator: Token) throws -> Double {
        guard let value = value as? Double else {
            throw RuntimeError.unknown(`operator`, "Operand must be a number.")
        }
        
        return value
    }
}

private extension Interpreter {
    static var createStaticGlobalEnvironment: Environment {
        let environment = Environment()
        let callable = ClockCallable()
        
        environment.define(name: "clock", value: callable)
        
        return environment
    }
}
