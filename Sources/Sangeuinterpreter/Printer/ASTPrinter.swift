//
//  ASTPrinter.swift
//  
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

class ASTPrinter {
    func print(expression: Expr) -> String {
        do {
            return try expression.accept(visitor: self)
        } catch {
            return error.localizedDescription
        }
    }
}

// MARK: - ExprVisitorProtocol
extension ASTPrinter: ExprVisitorProtocol {
    typealias ExprVisitorProtocolReturnType = String
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> String {
        return try parenthesize(name: expr._operator.lexeme, expressions: expr.left, expr.right)
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> String {
        return try parenthesize(name: "group", expressions: expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> String {
        guard let value = expr.value else {
            return "nil"
        }
        
        return "\(value)"
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> String {
        return try parenthesize(name: expr._operator.lexeme, expressions: expr.right)
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> String {
        return expr.name.lexeme
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> String {
        return ""
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> String {
        return try self.parenthesize(name: expr._operator.lexeme, expressions: expr.left, expr.right)
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> String {
        return ""
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> String {
        return ""
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> String {
        return ""
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> String {
        return ""
    }
}

private extension ASTPrinter {
    func parenthesize(name: String, expressions: Expr...) throws -> String {
        let operands = try expressions.map({ try $0.accept(visitor: self) }).joinedWithWhiteSpace
        
        return "(\(name) \(operands))"
    }
}

private extension [String] {
    var joinedWithWhiteSpace: String {
        return self.joined(separator: " ")
    }
}
