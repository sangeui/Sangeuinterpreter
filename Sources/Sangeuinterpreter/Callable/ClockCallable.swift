//
//  ClockCallable.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

final class ClockCallable {
    
}

extension ClockCallable: Callable {
    var arity: Int {
        return .zero
    }
    
    var description: String {
        return "<native fn>"
    }
    
    func call(interpreter: Interpreter, arguments: [Any?]) throws -> Any? {
        return Date().timeIntervalSince1970 as Double
    }
}
