//
//  VADefaultsTests+Codable.swift
//  
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

#if canImport(VADefaultsMacros)
extension VADefaultsTests {

    func test_defaultMacro_codable() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue()
            var value: MyCodable?
            """,
            expandedSource: """
            var value: MyCodable? {
                get {
                    UserDefaults.standard.data(forKey: "value").flatMap { try? decoder.decode(MyCodable.self, from: $0) }
                }
                set {
                    UserDefaults.standard.setValue(try? JSONEncoder().encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }
}
#endif
