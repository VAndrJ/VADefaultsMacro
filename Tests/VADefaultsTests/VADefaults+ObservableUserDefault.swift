//
//  VADefaults+ObservableUserDefault.swift
//  VADefaults
//
//  Created by VAndrJ on 12/11/24.
//

#if canImport(VADefaultsMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

extension VADefaultsTests {

    func test_observableUserDefaultMacro_class() throws {
        assertMacroExpansion(
            """
            @Observable
            @UserDefaultsData(defaults: .test)
            open class Defaults {
            }
            """,
            expandedSource: """
            @Observable
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

    func test_observableUserDefaultMacro_variable() throws {
        assertMacroExpansion(
            """
            @Observable
            @UserDefaultsData(defaults: .test)
            internal class Defaults {
                var someVariable: Int
                let someConstant = true
            }
            """,
            expandedSource: #"""
            @Observable
            internal class Defaults {
                @ObservationIgnored
                var someVariable: Int {
                    get {
                        access(keyPath: \.someVariable)
                        userDefaults.integer(forKey: "someVariable")
                    }
                    set {
                        withMutation(keyPath: \.someVariable) {
                            userDefaults.setValue(newValue, forKey: "someVariable")
                        }
                    }
                }
                let someConstant = true
            
                private let userDefaults: UserDefaults

                internal init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            """#,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_variableValue() throws {
        assertMacroExpansion(
            """
            @Observable
            @UserDefaultsData(defaults: SomeClass.staticDefaults)
            fileprivate class Defaults {
                @DefaultsValue(key: "customKey")
                var someVariable: Int
                let someConstant = true
                var someStandardVariable = true
                var computedVariable: Bool { true }
            }
            """,
            expandedSource: #"""
            @Observable
            fileprivate class Defaults {
                @ObservationIgnored
                var someVariable: Int {
                    get {
                        access(keyPath: \.someVariable)
                        userDefaults.integer(forKey: "customKey")
                    }
                    set {
                        withMutation(keyPath: \.someVariable) {
                            userDefaults.setValue(newValue, forKey: "customKey")
                        }
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
            """#,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_codableRaw() throws {
        assertMacroExpansion(
            """
            @Observable
            @UserDefaultsData(defaults: .test)
            private class Defaults {
                @RawDefaultsValue(rawType: Int.self)
                var rawRepresentableValue: MyRepresentableType?
                @CodableDefaultsValue(key: "customKey")
                var codableValue: MyCodableType?
            }
            """,
            expandedSource: #"""
            @Observable
            private class Defaults {
                @ObservationIgnored
                var rawRepresentableValue: MyRepresentableType? {
                    get {
                        access(keyPath: \.rawRepresentableValue)
                        (userDefaults.object(forKey: "rawRepresentableValue") as? Int).flatMap(MyRepresentableType.init(rawValue:))
                    }
                    set {
                        withMutation(keyPath: \.rawRepresentableValue) {
                            userDefaults.setValue(newValue?.rawValue, forKey: "rawRepresentableValue")
                        }
                    }
                }
                @ObservationIgnored
                var codableValue: MyCodableType? {
                    get {
                        access(keyPath: \.codableValue)
                        userDefaults.data(forKey: "customKey").flatMap {
                            try? JSONDecoder().decode(MyCodableType.self, from: $0)
                        }
                    }
                    set {
                        withMutation(keyPath: \.codableValue) {
                            userDefaults.set(try? JSONEncoder().encode(newValue), forKey: "customKey")
                        }
                    }
                }

                private let userDefaults: UserDefaults

                init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            """#,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_otherMacro() throws {
        assertMacroExpansion(
            """
            @Observable
            @UserDefaultsData(defaults: .test)
            final class Defaults {
                @SomeMacro
                var someVariable: Int
            }
            """,
            expandedSource: #"""
            @Observable
            final class Defaults {
                @SomeMacro
                @ObservationIgnored
                var someVariable: Int {
                    get {
                        access(keyPath: \.someVariable)
                        userDefaults.integer(forKey: "someVariable")
                    }
                    set {
                        withMutation(keyPath: \.someVariable) {
                            userDefaults.setValue(newValue, forKey: "someVariable")
                        }
                    }
                }

                private let userDefaults: UserDefaults

                init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            """#,
            macros: testMacros
        )
    }
}
#endif
