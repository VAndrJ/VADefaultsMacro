//
//  VADefaultsTests+TypesMatch.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

#if canImport(VADefaultsMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

extension VADefaultsTests {

    func test_defaultMacro_boolLiteral_bool_match() throws {
        assertMacroExpansion(
            """
            @UserDefaultsValue(defaultValue: true)
            var value: Bool
            """,
            expandedSource: """
                var value: Bool {
                    get {
                        UserDefaults.standard.register(defaults: ["value": true])
                        return UserDefaults.standard.bool(forKey: "value")
                    }
                    set {
                        UserDefaults.standard.setValue(newValue, forKey: "value")
                    }
                }
                """,
            macros: testMacros
        )
    }

    func test_defaultMacro_boolLiteral_boolOptional_match() throws {
        assertMacroExpansion(
            """
            @UserDefaultsValue(defaultValue: true)
            var value: Bool?
            """,
            expandedSource: """
                var value: Bool? {
                    get {
                        UserDefaults.standard.object(forKey: "value") as? Bool ?? true
                    }
                    set {
                        UserDefaults.standard.setValue(newValue, forKey: "value")
                    }
                }
                """,
            macros: testMacros
        )
    }

    func test_defaultMacro_boolLiteral_string_mismatch() throws {
        assertMacroExpansion(
            """
            @UserDefaultsValue(defaultValue: true)
            var value: String
            """,
            expandedSource: """
                var value: String
                """,
            diagnostics: [.init(message: UserDefaultsValueError.typesMismatch.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    // TODO: - Types array: [.string, .nsString]
    func test_defaultMacro_stringLiteral_string_match() throws {
        assertMacroExpansion(
            """
            @UserDefaultsValue(defaultValue: "A")
            var value: String
            """,
            expandedSource: """
                var value: String {
                    get {
                        UserDefaults.standard.string(forKey: "value") ?? "A"
                    }
                    set {
                        UserDefaults.standard.setValue(newValue, forKey: "value")
                    }
                }
                """,
            macros: testMacros
        )
    }

    // TODO: - Types array
    func test_defaultMacro_stringLiteral_int_mismatch() throws {
        assertMacroExpansion(
            """
            @UserDefaultsValue(defaultValue: "A")
            var value: Int
            """,
            expandedSource: """
                var value: Int
                """,
            diagnostics: [.init(message: UserDefaultsValueError.typesMismatch.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    // TODO: - Integer, Float literal types tests
}
#endif
