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
            @available(iOS 17.0, *)
            @ObservableUserDefaultsData(defaults: .test)
            open class Defaults {
            }
            """,
            expandedSource: """
            @available(iOS 17.0, *)
            open class Defaults {
            
                private let userDefaults: UserDefaults
            
                public init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<_TMember>(
                    keyPath: KeyPath<Defaults, _TMember>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
            
                internal nonisolated func withMutation<_TMember, _TMutationResult>(
                    keyPath: KeyPath<Defaults, _TMember>,
                    _ mutation: () throws -> _TMutationResult
                ) rethrows -> _TMutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            @available(iOS 17.0, *)
            extension Defaults: Observation.Observable {
            }
            """,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_implementedFunctions() throws {
        assertMacroExpansion(
            """
            @available(iOS 17.0, *)
            @ObservableUserDefaultsData(defaults: .test)
            open class Defaults {
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<_TObservableMember>(
                    keyPath: KeyPath<Defaults, _TObservableMember>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
            
                internal nonisolated func withMutation<_TObservableMember, _TMutationResult>(
                    keyPath: KeyPath<Defaults, _TObservableMember>,
                    _ mutation: () throws -> _TMutationResult
                ) rethrows -> _TMutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            """,
            expandedSource: """
            @available(iOS 17.0, *)
            open class Defaults {
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<_TObservableMember>(
                    keyPath: KeyPath<Defaults, _TObservableMember>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
            
                internal nonisolated func withMutation<_TObservableMember, _TMutationResult>(
                    keyPath: KeyPath<Defaults, _TObservableMember>,
                    _ mutation: () throws -> _TMutationResult
                ) rethrows -> _TMutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            
                private let userDefaults: UserDefaults
            
                public init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            }
            
            @available(iOS 17.0, *)
            extension Defaults: Observation.Observable {
            }
            """,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_struct() throws {
        assertMacroExpansion(
            """
            @ObservableUserDefaultsData
            public struct Defaults {
            }
            """,
            expandedSource: """
            public struct Defaults {
            }
            """,
            diagnostics: [
                .init(message: UserDefaultsValueError.classNeeded.description, line: 1, column: 1),
                .init(message: UserDefaultsValueError.classNeeded.description, line: 1, column: 1),
            ],
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_variable() throws {
        assertMacroExpansion(
            """
            @ObservableUserDefaultsData
            internal class Defaults {
                var someVariable: Int
                let someConstant = true
                var someObsVariable = 1
                @ObservationIgnored
                var someBool = true
            }
            """,
            expandedSource: #"""
            internal class Defaults {
                var someVariable: Int {
                    get {
                        access(keyPath: \.someVariable)
                        return userDefaults.integer(forKey: "someVariable")
                    }
                    set {
                        withMutation(keyPath: \.someVariable) {
                            userDefaults.setValue(newValue, forKey: "someVariable")
                        }
                    }
                }
                let someConstant = true
                @ObservationTracked
                var someObsVariable = 1
                @ObservationIgnored
                var someBool = true
            
                private let userDefaults: UserDefaults
            
                internal init(userDefaults: UserDefaults = UserDefaults.standard) {
                    self.userDefaults = userDefaults
                }
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<_TMember>(
                    keyPath: KeyPath<Defaults, _TMember>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
            
                internal nonisolated func withMutation<_TMember, _TMutationResult>(
                    keyPath: KeyPath<Defaults, _TMember>,
                    _ mutation: () throws -> _TMutationResult
                ) rethrows -> _TMutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            extension Defaults: Observation.Observable {
            }
            """#,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_codableRaw() throws {
        assertMacroExpansion(
            """
            @ObservableUserDefaultsData(defaults: .test)
            class Defaults {
                @RawDefaultsValue(rawType: Int.self)
                var rawRepresentableValue: MyRepresentableType?
                @RawDefaultsValue(rawType: Int.self, defaultValue: MyRepresentableType.one)
                var rawRepresentableWithDefaultValue: MyRepresentableType
                @CodableDefaultsValue(key: "customKey")
                var codableValue: MyCodableType?
                @CodableDefaultsValue(key: "customKey", defaultValue: MyCodableType())
                var codableWithDefaultValue: MyCodableType
            }
            """,
            expandedSource: #"""
            class Defaults {
                var rawRepresentableValue: MyRepresentableType? {
                    get {
                        access(keyPath: \.rawRepresentableValue)
                        return (userDefaults.object(forKey: "rawRepresentableValue") as? Int).flatMap(MyRepresentableType.init(rawValue:))
                    }
                    set {
                        withMutation(keyPath: \.rawRepresentableValue) {
                            userDefaults.setValue(newValue?.rawValue, forKey: "rawRepresentableValue")
                        }
                    }
                }
                var rawRepresentableWithDefaultValue: MyRepresentableType {
                    get {
                        access(keyPath: \.rawRepresentableWithDefaultValue)
                        return (userDefaults.object(forKey: "rawRepresentableWithDefaultValue") as? Int).flatMap(MyRepresentableType.init(rawValue:)) ?? MyRepresentableType.one
                    }
                    set {
                        withMutation(keyPath: \.rawRepresentableWithDefaultValue) {
                            userDefaults.setValue(newValue.rawValue, forKey: "rawRepresentableWithDefaultValue")
                        }
                    }
                }
                var codableValue: MyCodableType? {
                    get {
                        access(keyPath: \.codableValue)
                        return userDefaults.data(forKey: "customKey").flatMap {
                            try? JSONDecoder().decode(MyCodableType.self, from: $0)
                        }
                    }
                    set {
                        withMutation(keyPath: \.codableValue) {
                            userDefaults.set(try? JSONEncoder().encode(newValue), forKey: "customKey")
                        }
                    }
                }
                var codableWithDefaultValue: MyCodableType {
                    get {
                        access(keyPath: \.codableWithDefaultValue)
                        return userDefaults.data(forKey: "customKey").flatMap {
                            try? JSONDecoder().decode(MyCodableType.self, from: $0)
                        } ?? MyCodableType()
                    }
                    set {
                        withMutation(keyPath: \.codableWithDefaultValue) {
                            userDefaults.set(try? JSONEncoder().encode(newValue), forKey: "customKey")
                        }
                    }
                }
            
                private let userDefaults: UserDefaults
            
                init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<_TMember>(
                    keyPath: KeyPath<Defaults, _TMember>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
            
                internal nonisolated func withMutation<_TMember, _TMutationResult>(
                    keyPath: KeyPath<Defaults, _TMember>,
                    _ mutation: () throws -> _TMutationResult
                ) rethrows -> _TMutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            extension Defaults: Observation.Observable {
            }
            """#,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_otherMacro() throws {
        assertMacroExpansion(
            """
            @ObservableUserDefaultsData(defaults: .test)
            final class Defaults {
                @MyMacro
                var someVariable: Int
            }
            """,
            expandedSource: #"""
            final class Defaults {
                @MyMacro
                var someVariable: Int {
                    get {
                        access(keyPath: \.someVariable)
                        return userDefaults.integer(forKey: "someVariable")
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
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<_TMember>(
                    keyPath: KeyPath<Defaults, _TMember>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
            
                internal nonisolated func withMutation<_TMember, _TMutationResult>(
                    keyPath: KeyPath<Defaults, _TMember>,
                    _ mutation: () throws -> _TMutationResult
                ) rethrows -> _TMutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            extension Defaults: Observation.Observable {
            }
            """#,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_values() throws {
        assertMacroExpansion(
            """
            @available(iOS 17.0, *)
            @ObservableUserDefaultsData(defaults: .test)
            open class Defaults {
                @UserDefaultsValue(defaultValue: "a")
                var value: String
                @UserDefaultsValue(defaultValue: "a")
                static var staticValue: String
            }
            """,
            expandedSource: #"""
            @available(iOS 17.0, *)
            open class Defaults {
                var value: String {
                    get {
                        access(keyPath: \.value)
                        return UserDefaults.standard.string(forKey: "value") ?? "a"
                    }
                    set {
                        withMutation(keyPath: \.value) {
                            UserDefaults.standard.setValue(newValue, forKey: "value")
                        }
                    }
                }
                static var staticValue: String {
                    get {
                        UserDefaults.standard.string(forKey: "staticValue") ?? "a"
                    }
                    set {
                        UserDefaults.standard.setValue(newValue, forKey: "staticValue")
                    }
                }
            
                private let userDefaults: UserDefaults
            
                public init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<_TMember>(
                    keyPath: KeyPath<Defaults, _TMember>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }
            
                internal nonisolated func withMutation<_TMember, _TMutationResult>(
                    keyPath: KeyPath<Defaults, _TMember>,
                    _ mutation: () throws -> _TMutationResult
                ) rethrows -> _TMutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            @available(iOS 17.0, *)
            extension Defaults: Observation.Observable {
            }
            """#,
            macros: testMacros
        )
    }
}
#endif
