//
//  VADefaultsTests+RawRepresentable.swift
//
//
//  Created by Volodymyr Andriienko on 23.03.2024.
//

#if canImport(VADefaultsMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

extension VADefaultsTests {

    func test_defaultMacro_representable() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue(rawType: Int.self)
            var value: ExampleEnum?
            """,
            expandedSource: """
                var value: ExampleEnum? {
                    get {
                        (UserDefaults.standard.object(forKey: "value") as? Int).flatMap(ExampleEnum.init(rawValue:))
                    }
                    set {
                        UserDefaults.standard.setValue(newValue?.rawValue, forKey: "value")
                    }
                }
                """,
            macros: testMacros
        )
    }

    func test_defaultMacro_representable_failure() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue(rawType: Int.self)
            var value: ExampleEnum
            """,
            expandedSource: """
                var value: ExampleEnum
                """,
            diagnostics: [.init(message: UserDefaultsValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_representable_defaultValue() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue(rawType: Int.self, defaultValue: ExampleEnum.undefined)
            var value: ExampleEnum
            """,
            expandedSource: """
                var value: ExampleEnum {
                    get {
                        (UserDefaults.standard.object(forKey: "value") as? Int).flatMap(ExampleEnum.init(rawValue:)) ?? ExampleEnum.undefined
                    }
                    set {
                        UserDefaults.standard.setValue(newValue.rawValue, forKey: "value")
                    }
                }
                """,
            macros: testMacros
        )
    }

    func test_defaultMacro_representable_defaultValueMember() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue(rawType: Int.self, defaultValue: parameter)
            var value: ExampleEnum
            """,
            expandedSource: """
                var value: ExampleEnum {
                    get {
                        (UserDefaults.standard.object(forKey: "value") as? Int).flatMap(ExampleEnum.init(rawValue:)) ?? parameter
                    }
                    set {
                        UserDefaults.standard.setValue(newValue.rawValue, forKey: "value")
                    }
                }
                """,
            macros: testMacros
        )
    }

    func test_defaultMacro_representable_defaultValueDecl() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue(rawType: Int.self, defaultValue: Self.parameter)
            var value: ExampleEnum
            """,
            expandedSource: """
                var value: ExampleEnum {
                    get {
                        (UserDefaults.standard.object(forKey: "value") as? Int).flatMap(ExampleEnum.init(rawValue:)) ?? Self.parameter
                    }
                    set {
                        UserDefaults.standard.setValue(newValue.rawValue, forKey: "value")
                    }
                }
                """,
            macros: testMacros
        )
    }

    func test_defaultMacro_representable_notVariable() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue(rawType: Int.self)
            var (a, b): ExampleEnum
            """,
            expandedSource: """
                var (a, b): ExampleEnum
                """,
            diagnostics: [.init(message: UserDefaultsValueError.notVariable.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_representable_unsupportedType() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue(rawType: SomeCustomType.self)
            var value: ExampleEnum
            """,
            expandedSource: """
                var value: ExampleEnum
                """,
            diagnostics: [.init(message: UserDefaultsValueError.unsupportedType.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_representable_rawTypeRequired_unsupportedType() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultsValue()
            var value: ExampleEnum
            """,
            expandedSource: """
                var value: ExampleEnum
                """,
            diagnostics: [.init(message: UserDefaultsValueError.unsupportedType.description, line: 1, column: 1)],
            macros: testMacros
        )
    }
}
#endif
