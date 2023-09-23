//
//  Generator.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

final class Generator {
    
}

extension Generator {
    static func generate(directory: String, base: String, types: [String]) {
        let url = self.createURL(directory: directory, file: base)
        var contents = ""
        
        contents.append("//\n")
        contents.append("// \(base).swift\n")
        contents.append("//\n")
        contents.append("\nimport Foundation\n")
        
        // The Visitor protocol
        contents.append("\n")
        self.define(visitor: base, types: types, contents: &contents)
        
        // The Base class
        contents.append("\n")
        contents.append("class \(base) {\n")
        
        contents.append("\tfunc accept<V: \(base)VisitorProtocol, R>(visitor: V) throws -> R where R == V.\(base)VisitorProtocolReturnType {\n")
        contents.append("\t\tfatalError()\n")
        contents.append("\t}\n")
        
        // The AST classes.
        contents.append("\n")
        
        for type in types {
            let `class` = type.colonSeperated[.indexOfClassName].whiteSpacesTrimmed
            let fields = type.colonSeperated[.indexOfFields].whiteSpacesTrimmed
            
            self.define(class: `class`, fields: fields, base: base, contents: &contents)
        }
        contents.append("}")
        
        self.write(string: contents, url: url)
    }
}

// MARK: - Visitor
private extension Generator {
    static func define(visitor: String, types: [String], contents: inout String) {
        let associatedType = "\(visitor)VisitorProtocolReturnType"
        
        contents.append("protocol \(visitor)VisitorProtocol {\n")
        contents.append("\tassociatedtype \(associatedType)\n")
        contents.append("\n")
        
        for type in types {
            let typeName = type.colonSeperated[.indexOfClassName].whiteSpacesTrimmed
            let functionName = "visit\(typeName)\(visitor)"
            let parameters = "_ \(visitor.lowercased()): \(visitor).\(typeName)"
            
            contents.append("\tfunc \(functionName)(\(parameters)) throws -> \(associatedType)\n")
        }
        
        contents.append("}\n")
    }
}

// MARK: - Sub class
private extension Generator {
    static func define(class: String, fields: String, base: String, contents: inout String) {
        contents.append("\tclass \(`class`): \(base) {\n")
        
        // Fields
        for colonSeparatedFields in fields.colonSeperated {
            self.extract(fields: colonSeparatedFields).forEach({ (identifier, type) in
                contents.append("\t\tlet \(identifier): \(type)\n")
            })
        }
        
        // Initializer
        contents.append("\n")
        contents.append("\t\tinit(\(extractParameters(fields: fields))) {\n")
        
        for colonSeparatedFields in fields.colonSeperated {
            self.extract(fields: colonSeparatedFields).forEach({ (identifier, _) in
                contents.append("\t\t\tself.\(identifier) = \(identifier)\n")
            })
        }
        
        contents.append("\t\t}\n")
        
        // Override Methods
        contents.append("\n")
        contents.append("\t\toverride func accept<V: \(base)VisitorProtocol, R>(visitor: V) throws -> R where R == V.\(base)VisitorProtocolReturnType {\n")
        contents.append("\t\t\treturn try visitor.visit\(`class`)\(base)(self)\n")
        contents.append("\t\t}\n")
        
        contents.append("\t}\n\n")
    }
    
    static func extract(fields: String) -> [(identifier: String, type: String)] {
        fields.commaSeparated.map({ field in
            return (identifier: field.whiteSpaceSeparated[.indexOfFieldIdentifier],
                    type: field.whiteSpaceSeparated[.indexOfFieldType])
        })
    }
    
    static func extractParameters(fields: String) -> String {
        self.extract(fields: fields)
            .map({ (identifier, type) in
                return "\(identifier): \(type)"
            })
            .joined(separator: ", ")
    }
}

private extension Generator {
    static func createURL(directory: String, file: String) -> URL {
        let path = directory + "/" + file + ".swift"
        
        guard let url = URL(string: path) else {
            exit(.zero)
        }
        
        return url
    }
    
    static func write(string: String, url: URL) {
        do {
            try string.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
}

private extension Generator {
    
}

private extension String {
    var colonSeperated: [String] {
        return self.components(separatedBy: ":")
    }
    
    var commaSeparated: [String] {
        return self.components(separatedBy: ",")
    }
    
    var whiteSpaceSeparated: [String] {
        return self.components(separatedBy: " ")
    }
    
    var whiteSpacesTrimmed: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
}

private extension Int {
    static let indexOfClassName = 0
    static let indexOfFields = 1
    
    static let indexOfFieldIdentifier = 1
    static let indexOfFieldType = 0
}
