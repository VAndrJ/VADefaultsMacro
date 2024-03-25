//
//  VADefaultsTests+Types.swift
//  
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

#if canImport(VADefaultsMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

extension VADefaultsTests {

    func test_defaultMacro_bool() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Bool
            """,
            expandedSource: """
            var value: Bool {
                get {
                    UserDefaults.standard.bool(forKey: "value")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_bool_optional() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Bool?
            """,
            expandedSource: """
            var value: Bool? {
                get {
                    UserDefaults.standard.object(forKey: "value") as? Bool
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_int() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Int
            """,
            expandedSource: """
            var value: Int {
                get {
                    UserDefaults.standard.integer(forKey: "value")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_float() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Float
            """,
            expandedSource: """
            var value: Float {
                get {
                    UserDefaults.standard.float(forKey: "value")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_double() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Double
            """,
            expandedSource: """
            var value: Double {
                get {
                    UserDefaults.standard.double(forKey: "value")
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_string_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: String
            """,
            expandedSource: """
            var value: String
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_string() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: "a")
            var value: String
            """,
            expandedSource: """
            var value: String {
                get {
                    UserDefaults.standard.string(forKey: "value") ?? "a"
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_nsString_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: NSString
            """,
            expandedSource: """
            var value: NSString
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_nsString() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: "a")
            var value: NSString
            """,
            expandedSource: """
            var value: NSString {
                get {
                    UserDefaults.standard.object(forKey: "value") as? NSString ?? "a"
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_nsNumber_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: NSNumber
            """,
            expandedSource: """
            var value: NSNumber
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_nsNumber() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 42)
            var value: NSNumber
            """,
            expandedSource: """
            var value: NSNumber {
                get {
                    UserDefaults.standard.object(forKey: "value") as? NSNumber ?? 42
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_url_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: URL
            """,
            expandedSource: """
            var value: URL
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_url() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: someURL)
            var value: URL
            """,
            expandedSource: """
            var value: URL {
                get {
                    UserDefaults.standard.url(forKey: "value") ?? someURL
                }
                set {
                    UserDefaults.standard.set(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_date_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Date
            """,
            expandedSource: """
            var value: Date
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_date() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: Date(timeIntervalSince1970: 23))
            var value: Date
            """,
            expandedSource: """
            var value: Date {
                get {
                    UserDefaults.standard.object(forKey: "value") as? Date ?? Date(timeIntervalSince1970: 23)
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_nsDate_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: NSDate
            """,
            expandedSource: """
            var value: NSDate
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_nsDate() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: NSDate(timeIntervalSince1970: 23))
            var value: NSDate
            """,
            expandedSource: """
            var value: NSDate {
                get {
                    UserDefaults.standard.object(forKey: "value") as? NSDate ?? NSDate(timeIntervalSince1970: 23)
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_data_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Data
            """,
            expandedSource: """
            var value: Data
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_data() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: Data())
            var value: Data
            """,
            expandedSource: """
            var value: Data {
                get {
                    UserDefaults.standard.data(forKey: "value") ?? Data()
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_nsData_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: NSData
            """,
            expandedSource: """
            var value: NSData
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_nsData() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: NSData())
            var value: NSData
            """,
            expandedSource: """
            var value: NSData {
                get {
                    UserDefaults.standard.object(forKey: "value") as? NSData ?? NSData()
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: UInt
            """,
            expandedSource: """
            var value: UInt
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 4)
            var value: UInt
            """,
            expandedSource: """
            var value: UInt {
                get {
                    UserDefaults.standard.object(forKey: "value") as? UInt ?? 4
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_int8_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Int8
            """,
            expandedSource: """
            var value: Int8
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_int8() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: Int8
            """,
            expandedSource: """
            var value: Int8 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? Int8 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_int16_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Int16
            """,
            expandedSource: """
            var value: Int16
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_int16() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: Int16
            """,
            expandedSource: """
            var value: Int16 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? Int16 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_int32_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Int32
            """,
            expandedSource: """
            var value: Int32
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_int32() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: Int32
            """,
            expandedSource: """
            var value: Int32 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? Int32 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_int64_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: Int64
            """,
            expandedSource: """
            var value: Int64
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_int64() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: Int64
            """,
            expandedSource: """
            var value: Int64 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? Int64 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt8_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: UInt8
            """,
            expandedSource: """
            var value: UInt8
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt8() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: UInt8
            """,
            expandedSource: """
            var value: UInt8 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? UInt8 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt16_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: UInt16
            """,
            expandedSource: """
            var value: UInt16
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt16() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: UInt16
            """,
            expandedSource: """
            var value: UInt16 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? UInt16 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt32_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: UInt32
            """,
            expandedSource: """
            var value: UInt32
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt32() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: UInt32
            """,
            expandedSource: """
            var value: UInt32 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? UInt32 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt64_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: UInt64
            """,
            expandedSource: """
            var value: UInt64
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_uInt64() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: 0)
            var value: UInt64
            """,
            expandedSource: """
            var value: UInt64 {
                get {
                    UserDefaults.standard.object(forKey: "value") as? UInt64 ?? 0
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_array_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: [Int]
            """,
            expandedSource: """
            var value: [Int]
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_array() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: [0])
            var value: [Int]
            """,
            expandedSource: """
            var value: [Int] {
                get {
                    UserDefaults.standard.array(forKey: "value") as? [Int] ?? [0]
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_dict_failure() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: [String: Int]
            """,
            expandedSource: """
            var value: [String: Int]
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_dict_failureKeyType() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: [Int: Int]
            """,
            expandedSource: """
            var value: [Int: Int]
            """,
            diagnostics: [.init(message: UserDefaultValueError.dictKeyType.description, line: 1, column: 1)],
            macros: testMacros
        )
    }

    func test_defaultMacro_dict() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue(defaultValue: ["2": 42])
            var value: [String: Int]
            """,
            expandedSource: """
            var value: [String: Int] {
                get {
                    UserDefaults.standard.dictionary(forKey: "value") as? [String: Int] ?? ["2": 42]
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_dict_optional() throws {
        assertMacroExpansion(
            """
            @UserDefaultValue()
            var value: [String: Int]?
            """,
            expandedSource: """
            var value: [String: Int]? {
                get {
                    UserDefaults.standard.dictionary(forKey: "value") as? [String: Int]
                }
                set {
                    UserDefaults.standard.setValue(newValue, forKey: "value")
                }
            }
            """,
            macros: testMacros
        )
    }

    func test_defaultMacro_customType_failure() throws {
        #if canImport(VADefaultsMacros)
        assertMacroExpansion(
            #"""
            @UserDefaultValue()
            var value: CustomType
            """#,
            expandedSource: #"""
            var value: CustomType
            """#,
            diagnostics: [.init(message: UserDefaultValueError.unsupportedType.description, line: 1, column: 1)],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
#endif
