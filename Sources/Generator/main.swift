//
//  File.swift
//  
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

typealias Configuration = (key: String, values: [String])

func convert(configuration: Configuration) -> String {
    return configuration.key + ":" + configuration.values.joined(separator: ",")
}

var expressions: [Configuration] = [
    (key: "Binary", values: ["Expr left", "Token _operator", "Expr right"]),
    (key: "Unary", values: ["Token _operator", "Expr right"]),
    (key: "Grouping", values: ["Expr expression"]),
    (key: "Literal", values: ["Any? value"]),
    (key: "Variable", values: ["Token name"]),
    (key: "Assign", values: ["Token name", "Expr value"]),
    (key: "Logical", values: ["Expr left", "Token _operator", "Expr right"]),
    (key: "Call", values: ["Expr callee", "Token paren", "[Expr] arguments"]),
    (key: "Get", values: ["Expr object", "Token name"]),
    (key: "Set", values: ["Expr object", "Token name", "Expr value"]),
    (key: "This", values: ["Token keyword"])
]

var statements: [Configuration] = [
    (key: "Block", values: ["[Stmt] statements"]),
    (key: "Class", values: ["Token name", "[Stmt.Function] methods"]),
    (key: "Expression", values: ["Expr expression"]),
    (key: "Function", values: ["Token name", "[Token] parameters", "[Stmt] body"]),
    (key: "Print", values: ["Expr expression"]),
    (key: "Return", values: ["Token keyword", "Expr? value"]),
    (key: "Var", values: ["Token name", "Expr? initializer"]),
    (key: "If", values: ["Expr expression", "Stmt thenBranch", "Stmt? elseBranch"]),
    (key: "While", values: ["Expr condition", "Stmt body"])
]

Generator.generate(directory: directory(), base: "Expr", types: expressions.map(convert(configuration:)))
Generator.generate(directory: directory(), base: "Stmt", types: statements.map(convert(configuration:)))
