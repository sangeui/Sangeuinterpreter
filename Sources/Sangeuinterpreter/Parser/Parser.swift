//
//  Parser.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

class Parser {
    private let tokens: [Token]
    private var current: Int = .zero
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() -> [Stmt] {
        var statements: [Stmt] = .init()
        
        while self.isAtEnd() == false {
            if let statement = self.declaration() {
                statements.append(statement)
            }
        }
        
        return statements
    }
}

private extension Parser {
    func declaration() -> Stmt? {
        do {
            if self.match(types: .CLASS) {
                return try self.classDeclaration()
            }
            
            if self.match(types: .FUN) {
                return try self.function(kind: "function")
            }
            
            if self.match(types: .VAR) {
                return try self.variableDeclaration()
            }
            
            return try self.statement()
        } catch {
            self.synchronize()
            
            return nil
        }
    }
    
    func classDeclaration() throws -> Stmt {
        let name = try self.consume(type: .IDENTIFIER, message: "Expect class name.")
        
        try self.consume(type: .LEFT_BRACE, message: "Expect '{' before class body.")
        
        var methods: [Stmt.Function] = .init()
        
        while self.check(type: .RIGHT_BRACE) == false && self.isAtEnd() == false {
            methods.append(try self.function(kind: "method"))
        }
        
        try self.consume(type: .RIGHT_BRACE, message: "Expect '}' after class body.")

        
        return Stmt.Class(name: name, methods: methods)
    }
    
    func variableDeclaration() throws -> Stmt {
        let name = try self.consume(type: .IDENTIFIER, message: "Expect variable name.")
        var initializer: Expr? = nil
        
        if self.match(types: .EQUAL) {
            initializer = try self.expression()
        }
        
        try self.consume(type: .SEMICOLON, message: "Expect ';' after variable declaration.")
        
        return .Var(name: name, initializer: initializer)
    }
}

private extension Parser {
    func function(kind: String) throws -> Stmt.Function {
        let name = try self.consume(type: .IDENTIFIER, message: "Expect " + kind + " name.")
        
        try self.consume(type: .LEFT_PAREN, message: "'(' after " + kind + " name.")
        
        return .init(name: name, parameters: try functionParameters(), body: try functionBody(kind))
    }
    
    func functionParameters() throws -> [Token] {
        var parameters: [Token] = .init()
        
        if self.check(type: .RIGHT_PAREN) == false {
            repeat {
                if parameters.count >= 255 {
                    _ = error(token: self.peek(), message: "Can't have more than 255 parameters.")
                    continue
                }
                
                let parameter = try self.consume(type: .IDENTIFIER, message: "Expect parameter name.")
                parameters.append(parameter)
            } while self.match(types: .COMMA)
        }
        
        try self.consume(type: .RIGHT_PAREN, message: "Expect ')' after parameters.")
        
        return parameters
    }
    
    func functionBody(_ kind: String) throws -> [Stmt] {
        try self.consume(type: .LEFT_BRACE, message: "Expect '{' before " + kind + " body.")
        
        return try self.block()
    }
}

private extension Parser {
    func statement() throws -> Stmt {
        if self.match(types: .FOR) {
            return try self.forStatement()
        }
        
        if self.match(types: .IF) {
            return try self.ifStatement()
        }
        
        if self.match(types: .PRINT) {
            return try self.printStatement()
        }
        
        if self.match(types: .RETURN) {
            return try self.returnStatement()
        }
        
        if self.match(types: .WHILE) {
            return try self.whileStatement()
        }
        
        if self.match(types: .LEFT_BRACE) {
            return .Block(statements: try self.block())
        }
        
        return try self.expressionStatement()
    }
    
    func returnStatement() throws -> Stmt {
        let keyword = self.previous()
        var value: Expr? = nil
        
        if self.check(type: .SEMICOLON) == false {
            value = try self.expression()
        }
        
        try self.consume(type: .SEMICOLON, message: "Expect ';' after return value.")
        
        return .Return(keyword: keyword, value: value)
    }
    
    func printStatement() throws -> Stmt {
        let value = try self.expression()
        
        try self.consume(type: .SEMICOLON, message: "Expect ';' after value.")
        
        return .Print(expression: value)
    }
    
    func expressionStatement() throws -> Stmt {
        let expression = try self.expression()
        
        try self.consume(type: .SEMICOLON, message: "Expect ';' after expression.")
        
        return .Expression(expression: expression)
    }
    
    func whileStatement() throws -> Stmt {
        try self.consume(type: .LEFT_PAREN, message: "Expect '(' after 'while'.")
        let condition = try self.expression()
        try self.consume(type: .RIGHT_PAREN, message: "Expect ')' after condition.")
        
        let body = try self.statement()
        
        return .While(condition: condition, body: body)
    }
    
    func forStatement() throws -> Stmt {
        try self.consume(type: .LEFT_PAREN, message: "Expect '(' after 'for'.")
        
        let initializer: Stmt?
        
        if self.match(types: .SEMICOLON) {
            initializer = nil
        } else if self.match(types: .VAR) {
            initializer = try self.variableDeclaration()
        } else {
            initializer = try self.expressionStatement()
        }
        
        let condition = !self.check(type: .SEMICOLON) ? try expression() : Expr.Literal(value: true)
        try self.consume(type: .SEMICOLON, message: "Expect ';' after loop condition.")
        
        let increment = !self.check(type: .RIGHT_PAREN) ? try expression() : nil
        try self.consume(type: .RIGHT_PAREN, message: "Expect ')' after for clauses.")
        
        var body = try statement()
        
        if let increment {
            body = .Block(statements: [body, .Expression(expression: increment)])
        }
        
        body = .While(condition: condition, body: body)
        
        if let initializer {
            body = .Block(statements: [initializer, body])
        }
        
        return body
    }
}

private extension Parser {
    func ifStatement() throws -> Stmt {
        try self.consume(type: .LEFT_PAREN, message: "Expect '(' after 'if'.")
        let condition = try self.expression()
        try self.consume(type: .RIGHT_PAREN, message: "Expect ')' after 'condition.")
        
        let thenBranch = try self.statement()
        var elseBranch: Stmt? = nil
        
        if self.match(types: .ELSE) {
            elseBranch = try self.statement()
        }
        
        return .If(expression: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }
    
    func block() throws -> [Stmt] {
        var statements: [Stmt] = .init()
        
        while self.check(type: .RIGHT_BRACE) == false && self.isAtEnd() == false {
            if let declaration = self.declaration() {
                statements.append(declaration)
            }
        }
        
        try self.consume(type: .RIGHT_BRACE, message: "Expect '}' after block");
        
        return statements
    }
}

private extension Parser {
    func expression() throws -> Expr {
        return try assignment()
    }
    
    func assignment() throws -> Expr {
        let expression = try self.or()
        
        if match(types: .EQUAL) {
            let equals = self.previous()
            let value = try self.assignment()
            
            if let expression = expression as? Expr.Variable {
                let name = expression.name
                
                return .Assign(name: name, value: value)
            } else if let expression = expression as? Expr.Get {
                return .Set(object: expression.object, name: expression.name, value: value)
            }
            
            _ = error(token: equals, message: "Invalid assignment target.")
        }
        
        return expression
    }
    
    func or() throws -> Expr {
        var expression = try self.and()
        
        while self.match(types: .OR) {
            let `operator` = self.previous()
            let right = try self.and()
            
            expression = .Logical(left: expression, _operator: `operator`, right: right)
        }
        
        return expression
    }
    
    func and() throws -> Expr {
        var expression = try self.equality()
        
        while self.match(types: .AND) {
            let `operator` = self.previous()
            let right = try self.equality()
            
            expression = .Logical(left: expression, _operator: `operator`, right: right)
        }
        
        return expression
    }
    
    func equality() throws -> Expr {
        // equality -> comparison ( ( "!=" | "==" comparison )* ;
        
        var expression = try self.comparison()
        
        while (match(types: .BANG_EQUAL, .EQUAL_EQUAL)) {
            let `operator` = self.previous()
            let right = try self.comparison()
            
            expression = .Binary(left: expression, _operator: `operator`, right: right)
        }
        
        return expression
    }
    
    func comparison() throws -> Expr {
        // comparison -> term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
        
        var expression = try self.term()
        
        while (match(types: .GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL)) {
            let `operator` = self.previous()
            let right = try self.term()
            
            expression = .Binary(left: expression, _operator: `operator`, right: right)
        }
        
        return expression
    }
    
    func term() throws -> Expr {
        // term -> factor ( ( "-" | "+") factor )* ;
        
        var expression = try self.factor()
        
        while (match(types: .MINUS, .PLUS)) {
            let `operator` = self.previous()
            let right = try self.factor()
            
            expression = .Binary(left: expression, _operator: `operator`, right: right)
        }
        
        return expression
    }
    
    func factor() throws -> Expr {
        // factor -> unary ( ( "/" | "*" ) unary )* ;
        
        var expression = try self.unary()
        
        while (match(types: .SLASH, .STAR)) {
            let `operator` = self.previous()
            let right = try self.unary()
            
            expression = .Binary(left: expression, _operator: `operator`, right: right)
        }
        
        return expression
    }
    
    func unary() throws -> Expr {
        // unary -> ( "!" | "-" ) unary | call ;
        
        if match(types: .BANG, .MINUS) {
            let `operator` = self.previous()
            let right = try self.unary()
            
            return .Unary(_operator: `operator`, right: right)
        }
        
        return try self.call()
    }
    
    func call() throws -> Expr {
        var expression = try self.primary()
        
        while true {
            if self.match(types: .LEFT_PAREN) {
                expression = try self.finish(callee: expression)
            } else if self.match(types: .DOT) {
                let name = try self.consume(type: .IDENTIFIER, message: "Expect property name after '.'.")
                expression = .Get(object: expression, name: name)
            } else {
                break
            }
        }
        
        return expression
    }
    
    func finish(callee: Expr) throws -> Expr {
        var arguments = [Expr]()
        
        if self.check(type: .RIGHT_PAREN) == false {
            repeat {
                let argument = try self.expression()
                
                if arguments.count >= 255 {
                    _ = self.error(token: self.previous(), message: "Can't have more than 255 arguments.")
                    continue
                }
                
                arguments.append(argument)
            } while self.match(types: .COMMA)
        }
        
        let parenthesis = try self.consume(type: .RIGHT_PAREN, message: "Expect ')' after arguments.")
        
        return .Call(callee: callee, paren: parenthesis, arguments: arguments)
    }
    
    func primary() throws -> Expr {
        // primary -> NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER ;
        
        if match(types: .FALSE) {
            return .Literal(value: false)
        }
        
        if match(types: .TRUE) {
            return .Literal(value: true)
        }
        
        if match(types: .NIL) {
            return .Literal(value: nil)
        }
        
        if match(types: .NUMBER, .STRING) {
            return .Literal(value: self.previous().literal)
        }
        
        if match(types: .LEFT_PAREN) {
            let expression = try self.expression()
            
            try self.consume(type: .RIGHT_PAREN, message: "Expect ')' after expression.")
            
            return .Grouping(expression: expression)
        }
        
        if self.match(types: .THIS) {
            return .This(keyword: self.previous())
        }
        
        if self.match(types: .IDENTIFIER) {
            return .Variable(name: self.previous())
        }
        
        throw self.error(token: self.peek(), message: "Expect expression.")
    }
}

private extension Parser {
    func match(types: Token.`Type`...) -> Bool {
        for type in types {
            if self.check(type: type) {
                self.advance()
                return true
            }
        }
        
        return false
    }
    
    func check(type: Token.`Type`) -> Bool {
        if self.isAtEnd() {
            return false
        }
        
        return self.peek().type == type
    }
    
    @discardableResult
    func consume(type: Token.`Type`, message: String) throws -> Token {
        if self.check(type: type) {
            return advance()
        }
        
        throw self.error(token: peek(), message: message)
    }
}

private extension Parser {
    func isAtEnd() -> Bool {
        return self.peek().type == .EOF
    }
    
    @discardableResult
    func advance() -> Token {
        if self.isAtEnd() == false {
            self.current += 1
        }
        
        return self.previous()
    }
    
    func peek() -> Token {
        return self.tokens[self.current]
    }
    
    func previous() -> Token {
        return self.tokens[self.current - 1]
    }
}

private extension Parser {
    func error(token: Token, message: String) -> ParserError {
        Sangeuinterpreter.error(token: token, message: message)
        
        return .unknown
    }
    
    func synchronize() {
        self.advance()
        
        while isAtEnd() == false {
            if self.previous().type == .SEMICOLON {
                return
            }
            
            switch self.peek().type {
            case .CLASS, .FOR, .FUN, .IF, .PRINT, .RETURN, .VAR, .WHILE:
                return
            default:
                break
            }
            
            self.advance()
        }
    }
}
