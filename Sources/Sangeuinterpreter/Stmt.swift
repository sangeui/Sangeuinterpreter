//
// Stmt.swift
//

import Foundation

protocol StmtVisitorProtocol {
	associatedtype StmtVisitorProtocolReturnType

	func visitBlockStmt(_ stmt: Stmt.Block) throws -> StmtVisitorProtocolReturnType
	func visitClassStmt(_ stmt: Stmt.Class) throws -> StmtVisitorProtocolReturnType
	func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> StmtVisitorProtocolReturnType
	func visitFunctionStmt(_ stmt: Stmt.Function) throws -> StmtVisitorProtocolReturnType
	func visitPrintStmt(_ stmt: Stmt.Print) throws -> StmtVisitorProtocolReturnType
	func visitReturnStmt(_ stmt: Stmt.Return) throws -> StmtVisitorProtocolReturnType
	func visitVarStmt(_ stmt: Stmt.Var) throws -> StmtVisitorProtocolReturnType
	func visitIfStmt(_ stmt: Stmt.If) throws -> StmtVisitorProtocolReturnType
	func visitWhileStmt(_ stmt: Stmt.While) throws -> StmtVisitorProtocolReturnType
}

class Stmt {
	func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
		fatalError()
	}

	class Block: Stmt {
		let statements: [Stmt]

		init(statements: [Stmt]) {
			self.statements = statements
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitBlockStmt(self)
		}
	}

	class Class: Stmt {
		let name: Token
		let methods: [Stmt.Function]

		init(name: Token, methods: [Stmt.Function]) {
			self.name = name
			self.methods = methods
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitClassStmt(self)
		}
	}

	class Expression: Stmt {
		let expression: Expr

		init(expression: Expr) {
			self.expression = expression
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitExpressionStmt(self)
		}
	}

	class Function: Stmt {
		let name: Token
		let parameters: [Token]
		let body: [Stmt]

		init(name: Token, parameters: [Token], body: [Stmt]) {
			self.name = name
			self.parameters = parameters
			self.body = body
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitFunctionStmt(self)
		}
	}

	class Print: Stmt {
		let expression: Expr

		init(expression: Expr) {
			self.expression = expression
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitPrintStmt(self)
		}
	}

	class Return: Stmt {
		let keyword: Token
		let value: Expr?

		init(keyword: Token, value: Expr?) {
			self.keyword = keyword
			self.value = value
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitReturnStmt(self)
		}
	}

	class Var: Stmt {
		let name: Token
		let initializer: Expr?

		init(name: Token, initializer: Expr?) {
			self.name = name
			self.initializer = initializer
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitVarStmt(self)
		}
	}

	class If: Stmt {
		let expression: Expr
		let thenBranch: Stmt
		let elseBranch: Stmt?

		init(expression: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
			self.expression = expression
			self.thenBranch = thenBranch
			self.elseBranch = elseBranch
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitIfStmt(self)
		}
	}

	class While: Stmt {
		let condition: Expr
		let body: Stmt

		init(condition: Expr, body: Stmt) {
			self.condition = condition
			self.body = body
		}

		override func accept<V: StmtVisitorProtocol, R>(visitor: V) throws -> R where R == V.StmtVisitorProtocolReturnType {
			return try visitor.visitWhileStmt(self)
		}
	}

}