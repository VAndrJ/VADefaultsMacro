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
            @UserDefaultsData(defaults: .test)
            open class Defaults {
            }
            """,
            expandedSource: """
            open class Defaults {

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
            @UserDefaultsData
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
            @UserDefaultsData(defaults: .test)
            public enum Defaults {
            }
            """,
            expandedSource: """
            public enum Defaults {
            }
            """,
            diagnostics: [.init(message: UserDefaultsValueError.classOfStructNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_userDefaultMacro_variable() throws {
        assertMacroExpansion(
            """
            @UserDefaultsData(defaults: .test)
            internal class Defaults {
                var someVariable: Int
                let someConstant = true
            }
            """,
            expandedSource: """
            internal class Defaults {
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

                internal init(userDefaults: UserDefaults = UserDefaults.test) {
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
            @UserDefaultsData(defaults: SomeClass.staticDefaults)
            fileprivate class Defaults {
                @DefaultsValue(key: "customKey")
                var someVariable: Int
                let someConstant = true
                var someStandardVariable = true
                var computedVariable: Bool { true }
            }
            """,
            expandedSource: """
            fileprivate class Defaults {
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

                fileprivate init(userDefaults: UserDefaults = SomeClass.staticDefaults) {
                    self.userDefaults = userDefaults
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_userDefaultMacro_codableRaw() throws {
        assertMacroExpansion(
            """
            @UserDefaultsData(defaults: .test)
            private class Defaults {
                @RawDefaultsValue(rawType: Int.self)
                var rawRepresentableValue: MyRepresentableType?
                @CodableDefaultsValue(key: "customKey")
                var codableValue: MyCodableType?
            }
            """,
            expandedSource: """
            private class Defaults {
                var rawRepresentableValue: MyRepresentableType? {
                    get {
                        (userDefaults.object(forKey: "rawRepresentableValue") as? Int).flatMap(MyRepresentableType.init(rawValue:))
                    }
                    set {
                        userDefaults.setValue(newValue?.rawValue, forKey: "rawRepresentableValue")
                    }
                }
                var codableValue: MyCodableType? {
                    get {
                        userDefaults.data(forKey: "customKey").flatMap {
                            try? JSONDecoder().decode(MyCodableType.self, from: $0)
                        }
                    }
                    set {
                        userDefaults.set(try? JSONEncoder().encode(newValue), forKey: "customKey")
                    }
                }

                private let userDefaults: UserDefaults

                init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_userDefaultMacro_otherMacro() throws {
        assertMacroExpansion(
            """
            @UserDefaultsData(defaults: .test)
            final class Defaults {
                @Observable
                var someVariable: Int
            }
            """,
            expandedSource: """
            final class Defaults {
                @Observable
                var someVariable: Int {
                    get {
                        userDefaults.integer(forKey: "someVariable")
                    }
                    set {
                        userDefaults.setValue(newValue, forKey: "someVariable")
                    }
                }

                private let userDefaults: UserDefaults

                init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            """,
            macros: testMacros
        )
    }
}
#endif
