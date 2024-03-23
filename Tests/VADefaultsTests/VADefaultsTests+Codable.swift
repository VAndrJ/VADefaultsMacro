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
                    UserDefaults.standard.data(forKey: "value").flatMap {
                        try? JSONDecoder().decode(MyCodable.self, from: $0)
                    }
                }
                set {
                    UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_encoder() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue(encoder: myEncoder)
            var value: MyCodable?
            """,
            expandedSource: """
            var value: MyCodable? {
                get {
                    UserDefaults.standard.data(forKey: "value").flatMap {
                        try? JSONDecoder().decode(MyCodable.self, from: $0)
                    }
                }
                set {
                    UserDefaults.standard.set(try? myEncoder.encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_encoderDecl() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue(key: "customKey", encoder: Self.myEncoder)
            var value: MyCodable?
            """,
            expandedSource: """
            var value: MyCodable? {
                get {
                    UserDefaults.standard.data(forKey: "customKey").flatMap {
                        try? JSONDecoder().decode(MyCodable.self, from: $0)
                    }
                }
                set {
                    UserDefaults.standard.set(try? Self.myEncoder.encode(newValue), forKey: "customKey")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_decoder() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue(decoder: myDecoder)
            var value: MyCodable?
            """,
            expandedSource: """
            var value: MyCodable? {
                get {
                    UserDefaults.standard.data(forKey: "value").flatMap {
                        try? myDecoder.decode(MyCodable.self, from: $0)
                    }
                }
                set {
                    UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_decoderDecl() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue(defaults: .testDefaults, decoder: SomeClass.myDecoder)
            var value: MyCodable?
            """,
            expandedSource: """
            var value: MyCodable? {
                get {
                    UserDefaults.testDefaults.data(forKey: "value").flatMap {
                        try? SomeClass.myDecoder.decode(MyCodable.self, from: $0)
                    }
                }
                set {
                    UserDefaults.testDefaults.set(try? JSONEncoder().encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_defaultValue() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue(defaultValue: MyCodable())
            var value: MyCodable
            """,
            expandedSource: """
            var value: MyCodable {
                get {
                    UserDefaults.standard.data(forKey: "value").flatMap {
                        try? JSONDecoder().decode(MyCodable.self, from: $0)
                    } ?? MyCodable()
                }
                set {
                    UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_defaultValueMember() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue(defaultValue: myCodable)
            var value: MyCodable
            """,
            expandedSource: """
            var value: MyCodable {
                get {
                    UserDefaults.standard.data(forKey: "value").flatMap {
                        try? JSONDecoder().decode(MyCodable.self, from: $0)
                    } ?? myCodable
                }
                set {
                    UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_defaultValueDecl() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue(defaultValue: Self.myCodable)
            var value: MyCodable
            """,
            expandedSource: """
            var value: MyCodable {
                get {
                    UserDefaults.standard.data(forKey: "value").flatMap {
                        try? JSONDecoder().decode(MyCodable.self, from: $0)
                    } ?? Self.myCodable
                }
                set {
                    UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_codable_failure() throws {
        assertMacroExpansion(
            """
            @CodableUserDefaultValue()
            var value: MyCodable
            """,
            expandedSource: """
            var value: MyCodable
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }
}
#endif
