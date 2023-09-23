import Foundation

public class Sangeuinterpreter {
    static let interpreter: Interpreter = .init()
    
    public static func runPrompt() {
        print(">", terminator: "\t")

        while let line = readLine() {
            self.run(source: line)
            self.hadError = false
            print(">", terminator: "\t")
        }
    }
    
    public static func runFile(path: String) throws {
        let string: String = try .init(contentsOfFile: path, encoding: .utf8)
        
        self.run(source: string)
    }
    
    public static func run(source: String) {
        // Lexing
        let scanner: Scanner = .init(source: source)
        let tokens = scanner.scanTokens()
        
        // Parsing
        let parser: Parser = .init(tokens: tokens)
        let statements = parser.parse()
        
        guard self.hadError == false else {
            return
        }
        
        // Resolving
        let resolver = Resolver(interpreter: self.interpreter)
        resolver.resolve(statements: statements)
        
        guard self.hadError == false else {
            return
        }
        
        self.interpreter.interpret(statements: statements)
    }
}

extension Sangeuinterpreter {
    static var hadError: Bool = false
    static var hadruntimeError: Bool = false
    
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
    
    static func error(runtimeError: RuntimeError) {
        switch runtimeError {
        case .unknown(let token, let message):
            print(message)
            print("[line \(token.line)]")
        case .message(let message):
            print(message)
        }
        
        self.hadruntimeError = true
    }
}
