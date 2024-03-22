import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(VADefaultsMacros)
import VADefaultsMacros

let testMacros: [String: Macro.Type] = [
    "UserDefaultValue": UserDefaultValue.self,
]
#endif

final class VADefaultsTests: XCTestCase {
    let testDefaults = UserDefaults(suiteName: "com.vandrj.test")

    func test_defaultMacro_standard() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standardExplicit() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(defaults: .standard)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_nilableValue() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var launchesCount: Int?
            """,
            expandedSource: """
            var launchesCount: Int? {
                get {
                    UserDefaults.standard.object(forKey: "launchesCount") as? Int
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_nilableValue_defaultValue() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 42)
            var launchesCount: Int?
            """,
            expandedSource: """
            var launchesCount: Int? {
                get {
                    UserDefaults.standard.object(forKey: "launchesCount") as? Int ?? 42
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customKey() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(key: "key")
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.integer(forKey: "key")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "key")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customKeyProperty() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(key: key)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.integer(forKey: key)
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: key)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customKeyStaticProperty() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(key: Self.key)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.integer(forKey: Self.key)
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: Self.key)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customKeyOtherClassStaticProperty() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(key: SomeClass.key)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.integer(forKey: SomeClass.key)
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: SomeClass.key)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customDefaultValue() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 42)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.register(defaults: ["launchesCount": 42])
                    return UserDefaults.standard.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customDefaultValueParamter() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: value)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.register(defaults: ["launchesCount": value])
                    return UserDefaults.standard.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customDefaultValueStaticParameter() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: Self.value)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.register(defaults: ["launchesCount": Self.value])
                    return UserDefaults.standard.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_standard_customDefaultValueOtherClassStaticParameter() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: SomeAwesomeClass.value)
            var launchesCount: Int
            """,
            expandedSource: """
            var launchesCount: Int {
                get {
                    UserDefaults.standard.register(defaults: ["launchesCount": SomeAwesomeClass.value])
                    return UserDefaults.standard.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "launchesCount")
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_custom() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: testDefaults)
            var launchesCount: Int
            """#,
            expandedSource: #"""
            var launchesCount: Int {
                get {
                    testDefaults.integer(forKey: "launchesCount")
                }
                set {
                    testDefaults.setValue(newValue, forKey: "launchesCount")
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_customMember() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: .testDefaults)
            var launchesCount: Int
            """#,
            expandedSource: #"""
            var launchesCount: Int {
                get {
                    UserDefaults.testDefaults.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.testDefaults.setValue(newValue, forKey: "launchesCount")
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_customMemberExplicit() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: UserDefaults.testDefaults)
            var launchesCount: Int
            """#,
            expandedSource: #"""
            var launchesCount: Int {
                get {
                    UserDefaults.testDefaults.integer(forKey: "launchesCount")
                }
                set {
                    UserDefaults.testDefaults.setValue(newValue, forKey: "launchesCount")
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func test_defaultMacro_mixed() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            #"""
            @UserDefaultValue(key: "customKey", defaultValue: 3, defaults: .testDefaults)
            var launchesCount: Int
            """#,
            expandedSource: #"""
            var launchesCount: Int {
                get {
                    UserDefaults.testDefaults.register(defaults: ["customKey": 3])
                    return UserDefaults.testDefaults.integer(forKey: "customKey")
                }
                set {
                    UserDefaults.testDefaults.setValue(newValue, forKey: "customKey")
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
