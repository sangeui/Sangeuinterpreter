//
// Expr.swift
//

import Foundation

protocol ExprVisitorProtocol {
	associatedtype ExprVisitorProtocolReturnType

	func visitBinaryExpr(_ expr: Expr.Binary) throws -> ExprVisitorProtocolReturnType
	func visitUnaryExpr(_ expr: Expr.Unary) throws -> ExprVisitorProtocolReturnType
	func visitGroupingExpr(_ expr: Expr.Grouping) throws -> ExprVisitorProtocolReturnType
	func visitLiteralExpr(_ expr: Expr.Literal) throws -> ExprVisitorProtocolReturnType
	func visitVariableExpr(_ expr: Expr.Variable) throws -> ExprVisitorProtocolReturnType
	func visitAssignExpr(_ expr: Expr.Assign) throws -> ExprVisitorProtocolReturnType
	func visitLogicalExpr(_ expr: Expr.Logical) throws -> ExprVisitorProtocolReturnType
	func visitCallExpr(_ expr: Expr.Call) throws -> ExprVisitorProtocolReturnType
	func visitGetExpr(_ expr: Expr.Get) throws -> ExprVisitorProtocolReturnType
	func visitSetExpr(_ expr: Expr.Set) throws -> ExprVisitorProtocolReturnType
	func visitThisExpr(_ expr: Expr.This) throws -> ExprVisitorProtocolReturnType
}

class Expr {
	func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
		fatalError()
	}

	class Binary: Expr {
		let left: Expr
		let _operator: Token
		let right: Expr

		init(left: Expr, _operator: Token, right: Expr) {
			self.left = left
			self._operator = _operator
			self.right = right
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitBinaryExpr(self)
		}
	}

	class Unary: Expr {
		let _operator: Token
		let right: Expr

		init(_operator: Token, right: Expr) {
			self._operator = _operator
			self.right = right
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitUnaryExpr(self)
		}
	}

	class Grouping: Expr {
		let expression: Expr

		init(expression: Expr) {
			self.expression = expression
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitGroupingExpr(self)
		}
	}

	class Literal: Expr {
		let value: Any?

		init(value: Any?) {
			self.value = value
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitLiteralExpr(self)
		}
	}

	class Variable: Expr {
		let name: Token

		init(name: Token) {
			self.name = name
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitVariableExpr(self)
		}
	}

	class Assign: Expr {
		let name: Token
		let value: Expr

		init(name: Token, value: Expr) {
			self.name = name
			self.value = value
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitAssignExpr(self)
		}
	}

	class Logical: Expr {
		let left: Expr
		let _operator: Token
		let right: Expr

		init(left: Expr, _operator: Token, right: Expr) {
			self.left = left
			self._operator = _operator
			self.right = right
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitLogicalExpr(self)
		}
	}

	class Call: Expr {
		let callee: Expr
		let paren: Token
		let arguments: [Expr]

		init(callee: Expr, paren: Token, arguments: [Expr]) {
			self.callee = callee
			self.paren = paren
			self.arguments = arguments
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitCallExpr(self)
		}
	}

	class Get: Expr {
		let object: Expr
		let name: Token

		init(object: Expr, name: Token) {
			self.object = object
			self.name = name
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitGetExpr(self)
		}
	}

	class Set: Expr {
		let object: Expr
		let name: Token
		let value: Expr

		init(object: Expr, name: Token, value: Expr) {
			self.object = object
			self.name = name
			self.value = value
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitSetExpr(self)
		}
	}

	class This: Expr {
		let keyword: Token

		init(keyword: Token) {
			self.keyword = keyword
		}

		override func accept<V: ExprVisitorProtocol, R>(visitor: V) throws -> R where R == V.ExprVisitorProtocolReturnType {
			return try visitor.visitThisExpr(self)
		}
	}

}