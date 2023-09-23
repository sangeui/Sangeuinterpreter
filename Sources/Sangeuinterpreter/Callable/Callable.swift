//
//  Callable.swift
//  
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

protocol Callable: CustomStringConvertible {
    var arity: Int { get }
    
    func call(interpreter: Interpreter, arguments: [Any?]) throws -> Any?
}
