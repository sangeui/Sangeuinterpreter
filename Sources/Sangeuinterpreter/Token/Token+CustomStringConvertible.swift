//
//  Token+CustomStringConvertible.swift
//
//
//  Created by Sangeui on 23/09/2023.
//

import Foundation

extension Token: CustomStringConvertible {
    var description: String {
        return "\(self.type) \(self.lexeme) \(self.literal ?? "")"
    }
}
