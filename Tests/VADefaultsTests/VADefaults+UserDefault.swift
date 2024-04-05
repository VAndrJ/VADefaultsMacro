//
//  VADefaults+UserDefault.swift
//  
//
//  Created by Volodymyr Andriienko on 05.04.2024.
//

#if canImport(VADefaultsMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

extension VADefaultsTests {

    func test_userDefaultMacro_class() throws {
        assertMacroExpansion(
            """
            @UserDefault(defaults: .test)
            public class Defaults {
            }
            """,
            expandedSource: """
            public class Defaults {

                private let userDefaults: UserDefaults

                public init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_userDefaultMacro_struct() throws {
        assertMacroExpansion(
            """
            @UserDefault
            public struct Defaults {
            }
            """,
            expandedSource: """
            public struct Defaults {

                private let userDefaults: UserDefaults

                public init(userDefaults: UserDefaults = UserDefaults.standard) {
                    self.userDefaults = userDefaults
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_userDefaultMacro_failure() throws {
        assertMacroExpansion(
            """
            @UserDefault(defaults: .test)
            public enum Defaults {
            }
            """,
            expandedSource: """
            public enum Defaults {
            }
            """,
            diagnostics: [.init(message: UserDefaultValueError.classOfStructNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_userDefaultMacro_variable() throws {
        assertMacroExpansion(
            """
            @UserDefault(defaults: .test)
            public class Defaults {
                var someVariable: Int
                let someConstant = true
            }
            """,
            expandedSource: """
            public class Defaults {
                var someVariable: Int {
                    get {
                        userDefaults.integer(forKey: "someVariable")
                    }
                    set {
                        userDefaults.setValue(newValue, forKey: "someVariable")
                    }
                }
                let someConstant = true

                private let userDefaults: UserDefaults

                public init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_userDefaultMacro_variableValue() throws {
        assertMacroExpansion(
            """
            @UserDefault(defaults: SomeClass.staticDefaults)
            public class Defaults {
                static var staticVariable: Int
                @DefaultValue(key: "customKey")
                var someVariable: Int
                let someConstant = true
                var someStandardVariable = true
                var computedVariable: Bool { true }
            }
            """,
            expandedSource: """
            public class Defaults {
                static var staticVariable: Int {
                    get {
                        userDefaults.integer(forKey: "staticVariable")
                    }
                    set {
                        userDefaults.setValue(newValue, forKey: "staticVariable")
                    }
                }
                var someVariable: Int {
                    get {
                        userDefaults.integer(forKey: "customKey")
                    }
                    set {
                        userDefaults.setValue(newValue, forKey: "customKey")
                    }
                }
                let someConstant = true
                var someStandardVariable = true
                var computedVariable: Bool { true }

                private let userDefaults: UserDefaults

                public init(userDefaults: UserDefaults = SomeClass.staticDefaults) {
                    self.userDefaults = userDefaults
                }
            }
            """,
            macros: testMacros
        )
    }
}
#endif
