import Foundation

public class Sangeuinterpreter {
    
}

extension Sangeuinterpreter {
    static var hadError: Bool = false
    
    static func report(line: Int, where: String, message: String) {
        print("[line \(line)] Error\(`where`): \(message)")
        
        self.hadError = true
    }
    
    static func error(line: Int, message: String) {
        self.report(line: line, where: "", message: message)
    }
    
    static func error(token: Token, message: String) {
        if token.type == .EOF {
            report(line: token.line, where: " at end", message: message)
        } else {
            report(line: token.line, where: " at '\(token.lexeme)'", message: message)
        }
    }
}
