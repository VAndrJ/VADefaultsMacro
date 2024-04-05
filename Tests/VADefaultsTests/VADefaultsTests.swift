#if canImport(VADefaultsMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

import VADefaultsMacros

let testMacros: [String: Macro.Type] = [
    "UserDefaultValue": UserDefaultValue.self,
    "CodableUserDefaultValue": CodableUserDefaultValue.self,
    "RawUserDefaultValue": RawUserDefaultValue.self,
    "UserDefault": UserDefault.self,
    "DefaultValue": DefaultValue.self,
    "CodableDefaultValue": CodableDefaultValue.self,
    "RawDefaultValue": RawDefaultValue.self,
]

final class VADefaultsTests: XCTestCase {
    let testDefaults = UserDefaults(suiteName: "com.vandrj.test")

    func test_defaultMacro_standard() throws {
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
    }

    func test_defaultMacro_standardExplicit() throws {
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
    }

    func test_defaultMacro_standard_nilableValue() throws {
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
    }

    func test_defaultMacro_standard_nilableValue_defaultValue() throws {
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
    }

    func test_defaultMacro_standard_customKey() throws {
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
    }

    func test_defaultMacro_standard_customKeyProperty() throws {
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
    }

    func test_defaultMacro_standard_customKeyStaticProperty() throws {
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
    }

    func test_defaultMacro_standard_customKeyOtherClassStaticProperty() throws {
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
    }

    func test_defaultMacro_standard_customDefaultValue() throws {
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
    }

    func test_defaultMacro_standard_customDefaultValueParamter() throws {
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
    }

    func test_defaultMacro_standard_customDefaultValueStaticParameter() throws {
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
    }

    func test_defaultMacro_standard_customDefaultValueOtherClassStaticParameter() throws {
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
    }

    func test_defaultMacro_custom() throws {
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
    }

    func test_defaultMacro_customMember() throws {
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
    }

    func test_defaultMacro_customMemberExplicit() throws {
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
    }

    func test_defaultMacro_floatLiteral() throws {
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: UserDefaults.testDefaults, defaultValue: 3.14)
            var value: NSNumber
            """#,
            expandedSource: #"""
            var value: NSNumber {
                get {
                    UserDefaults.testDefaults.object(forKey: "value") as? NSNumber ?? 3.14
                }
                set {
                    UserDefaults.testDefaults.setValue(newValue, forKey: "value")
                }
            }
            """#,
            macros: testMacros
        )
    }

    func test_defaultMacro_stringLiteral() throws {
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: UserDefaults.testDefaults, defaultValue: "A")
            var value: NSString?
            """#,
            expandedSource: #"""
            var value: NSString? {
                get {
                    UserDefaults.testDefaults.object(forKey: "value") as? NSString ?? "A"
                }
                set {
                    UserDefaults.testDefaults.setValue(newValue, forKey: "value")
                }
            }
            """#,
            macros: testMacros
        )
    }

    func test_defaultMacro_floatLiteral_matchOptional() throws {
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: UserDefaults.testDefaults, defaultValue: 3.14)
            var value: Double?
            """#,
            expandedSource: #"""
            var value: Double? {
                get {
                    UserDefaults.testDefaults.object(forKey: "value") as? Double ?? 3.14
                }
                set {
                    UserDefaults.testDefaults.setValue(newValue, forKey: "value")
                }
            }
            """#,
            macros: testMacros
        )
    }

    func test_defaultMacro_floatLiteral_match() throws {
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: UserDefaults.testDefaults, defaultValue: 3.14)
            var value: Float
            """#,
            expandedSource: #"""
            var value: Float {
                get {
                    UserDefaults.testDefaults.register(defaults: ["value": 3.14])
                    return UserDefaults.testDefaults.float(forKey: "value")
                }
                set {
                    UserDefaults.testDefaults.setValue(newValue, forKey: "value")
                }
            }
            """#,
            macros: testMacros
        )
    }

    func test_defaultMacro_floatLiteral_mismatch() throws {
        assertMacroExpansion(
            #"""
            @UserDefaultValue(defaults: UserDefaults.testDefaults, defaultValue: 3.14)
            var value: Int
            """#,
            expandedSource: #"""
            var value: Int
            """#,
            diagnostics: [.init(message: UserDefaultValueError.typesMismatch.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_mixed() throws {
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
    }

    func test_defaultMacro_notVariable() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var (a, b): Int
            """,
            expandedSource: """
            var (a, b): Int
            """,
            diagnostics: [.init(message: UserDefaultValueError.notVariable.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_typesMismatch_int_string() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 1)
            var value: String
            """,
            expandedSource: """
            var value: String
            """,
            diagnostics: [.init(message: UserDefaultValueError.typesMismatch.description, line: 1, column: 1)],
            macros: testMacros
        )
    }
}
#endif
