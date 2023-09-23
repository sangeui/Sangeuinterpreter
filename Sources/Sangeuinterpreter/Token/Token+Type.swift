//
//  Token+Type.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

extension Token {
    enum `Type` { 
        case LEFT_PAREN
        case RIGHT_PAREN
        case LEFT_BRACE
        case RIGHT_BRACE
        case COMMA
        case DOT
        case SEMICOLON
        case SLASH
        case STAR
        case MINUS
        case PLUS
        case BANG
        case BANG_EQUAL
        case EQUAL
        case EQUAL_EQUAL
        case GREATER
        case GREATER_EQUAL
        case LESS
        case LESS_EQUAL
        case IDENTIFIER
        case STRING
        case NUMBER
        case AND
        case OR
        case TRUE
        case FALSE
        case IF
        case ELSE
        case FOR
        case WHILE
        case CLASS
        case SUPER
        case THIS
        case FUN
        case NIL
        case PRINT
        case RETURN
        case VAR
        case EOF
    }
}
