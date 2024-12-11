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
            @ObservableUserDefaultsData(defaults: .test)
            open class Defaults {
            }
            """,
            expandedSource: """
            open class Defaults {

                private let userDefaults: UserDefaults

                public init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Defaults, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Defaults, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            extension Defaults: Observation.Observable {
            }
            """,
            macros: testMacros
        )
    }

    func test_observableUserDefaultMacro_variable() throws {
        assertMacroExpansion(
            """
            @ObservableUserDefaultsData(defaults: .test)
            internal class Defaults {
                var someVariable: Int
                let someConstant = true
                var someObsVariable = 1
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
            
                private let userDefaults: UserDefaults

                internal init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Defaults, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Defaults, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            extension Defaults: Observation.Observable {
            }
            """#,
            macros: testMacros
        )
    }
//
//    func test_userDefaultMacro_variableValue() throws {
//        assertMacroExpansion(
//            """
//            @UserDefaultsData(defaults: SomeClass.staticDefaults)
//            fileprivate class Defaults {
//                @DefaultsValue(key: "customKey")
//                var someVariable: Int
//                let someConstant = true
//                var someStandardVariable = true
//                var computedVariable: Bool { true }
//            }
//            """,
//            expandedSource: """
//            fileprivate class Defaults {
//                var someVariable: Int {
//                    get {
//                        userDefaults.integer(forKey: "customKey")
//                    }
//                    set {
//                        userDefaults.setValue(newValue, forKey: "customKey")
//                    }
//                }
//                let someConstant = true
//                var someStandardVariable = true
//                var computedVariable: Bool { true }
//
//                private let userDefaults: UserDefaults
//
//                fileprivate init(userDefaults: UserDefaults = SomeClass.staticDefaults) {
//                    self.userDefaults = userDefaults
//                }
//            }
//            """,
//            macros: testMacros
//        )
//    }
//
    func test_observableUserDefaultMacro_codableRaw() throws {
        assertMacroExpansion(
            """
            @ObservableUserDefaultsData(defaults: .test)
            class Defaults {
                @RawDefaultsValue(rawType: Int.self)
                var rawRepresentableValue: MyRepresentableType?
                @CodableDefaultsValue(key: "customKey")
                var codableValue: MyCodableType?
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

                private let userDefaults: UserDefaults

                init(userDefaults: UserDefaults = UserDefaults.test) {
                    self.userDefaults = userDefaults
                }
            
                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()
            
                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Defaults, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Defaults, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
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
            
                internal nonisolated func access<Member>(
                    keyPath: KeyPath<Defaults, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<Defaults, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }
            
            extension Defaults: Observation.Observable {
            }
            """#,
            macros: testMacros
        )
    }
}
#endif
