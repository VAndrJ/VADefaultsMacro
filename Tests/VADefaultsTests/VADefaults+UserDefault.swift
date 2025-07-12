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
            diagnostics: [.init(message: UserDefaultsValueError.classOrStructNeeded.description, line: 1, column: 1)],
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
                var computedVariable1: Bool { 
                    get { true }
                    set { _ = newValue }
                }
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
                    var computedVariable1: Bool { 
                        get { true }
                        set { _ = newValue }
                    }

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

    func test_userDefaultMacro_explicitStatic_notAllowed() throws {
        assertMacroExpansion(
            """
            @UserDefaultsData()
            class Defaults {
                @DefaultsValue
                static var someVariable: Int
                @CodableDefaultsValue
                static var someCodableVariable: SomeCodable
                @RawDefaultsValue
                static var someRawVariable: SomeRaw
                @DefaultsValue
                class var someClassVariable: Int
                @CodableDefaultsValue
                class var someClassCodableVariable: SomeCodable
                @RawDefaultsValue
                class var someClassRawVariable: SomeRaw
            }
            """,
            expandedSource: """
                class Defaults {
                    static var someVariable: Int
                    static var someCodableVariable: SomeCodable
                    static var someRawVariable: SomeRaw
                    class var someClassVariable: Int
                    class var someClassCodableVariable: SomeCodable
                    class var someClassRawVariable: SomeRaw

                    private let userDefaults: UserDefaults

                    init(userDefaults: UserDefaults = UserDefaults.standard) {
                        self.userDefaults = userDefaults
                    }
                }
                """,
            diagnostics: [
                .init(message: UserDefaultsValueError.staticVariable.description, line: 3, column: 5),
                .init(message: UserDefaultsValueError.staticVariable.description, line: 5, column: 5),
                .init(message: UserDefaultsValueError.staticVariable.description, line: 7, column: 5),
                .init(message: UserDefaultsValueError.staticVariable.description, line: 9, column: 5),
                .init(message: UserDefaultsValueError.staticVariable.description, line: 11, column: 5),
                .init(message: UserDefaultsValueError.staticVariable.description, line: 13, column: 5),
            ],
            macros: testMacros
        )
    }

    func test_userDefaultMacro_keyPrefix() throws {
        assertMacroExpansion(
            """
            @UserDefaultsData(defaults: .test, keyPrefix: "com.vandrj.")
            internal class Defaults {
                @CodableDefaultsValue(key: "codableCustomKey")
                var codableValue: MyCodableType?
                @CodableDefaultsValue
                var codableValue1: MyCodableType?
                @RawDefaultsValue(rawType: Int.self)
                var rawRepresentableValue: MyRepresentableType?
                @RawDefaultsValue(key: "rawCustomKey", rawType: Int.self)
                var rawRepresentableValue1: MyRepresentableType?
                @DefaultsValue
                var someVariable: Int
                @UserDefaultsValue
                var someVariable1: Int
                @DefaultsValue(key: "customKey")
                var someVariable2: Int
            }
            """,
            expandedSource: """
                internal class Defaults {
                    var codableValue: MyCodableType? {
                        get {
                            userDefaults.data(forKey: "codableCustomKey").flatMap {
                                try? JSONDecoder().decode(MyCodableType.self, from: $0)
                            }
                        }
                        set {
                            userDefaults.set(try? JSONEncoder().encode(newValue), forKey: "codableCustomKey")
                        }
                    }
                    var codableValue1: MyCodableType? {
                        get {
                            userDefaults.data(forKey: "com.vandrj.codableValue1").flatMap {
                                try? JSONDecoder().decode(MyCodableType.self, from: $0)
                            }
                        }
                        set {
                            userDefaults.set(try? JSONEncoder().encode(newValue), forKey: "com.vandrj.codableValue1")
                        }
                    }
                    var rawRepresentableValue: MyRepresentableType? {
                        get {
                            (userDefaults.object(forKey: "com.vandrj.rawRepresentableValue") as? Int).flatMap(MyRepresentableType.init(rawValue:))
                        }
                        set {
                            userDefaults.setValue(newValue?.rawValue, forKey: "com.vandrj.rawRepresentableValue")
                        }
                    }
                    var rawRepresentableValue1: MyRepresentableType? {
                        get {
                            (userDefaults.object(forKey: "rawCustomKey") as? Int).flatMap(MyRepresentableType.init(rawValue:))
                        }
                        set {
                            userDefaults.setValue(newValue?.rawValue, forKey: "rawCustomKey")
                        }
                    }
                    var someVariable: Int {
                        get {
                            userDefaults.integer(forKey: "com.vandrj.someVariable")
                        }
                        set {
                            userDefaults.setValue(newValue, forKey: "com.vandrj.someVariable")
                        }
                    }
                    var someVariable1: Int {
                        get {
                            UserDefaults.standard.integer(forKey: "someVariable1")
                        }
                        set {
                            UserDefaults.standard.setValue(newValue, forKey: "someVariable1")
                        }
                    }
                    var someVariable2: Int {
                        get {
                            userDefaults.integer(forKey: "customKey")
                        }
                        set {
                            userDefaults.setValue(newValue, forKey: "customKey")
                        }
                    }

                    private let userDefaults: UserDefaults

                    internal init(userDefaults: UserDefaults = UserDefaults.test) {
                        self.userDefaults = userDefaults
                    }
                }
                """,
            macros: testMacros
        )
    }
}
#endif
