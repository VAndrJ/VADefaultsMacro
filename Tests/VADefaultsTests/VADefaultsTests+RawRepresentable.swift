//
//  VADefaultsTests+RawRepresentable.swift
//  
//
//  Created by Volodymyr Andriienko on 23.03.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import VADefaultsMacros

#if canImport(VADefaultsMacros)
extension VADefaultsTests {

    func test_defaultMacro_representable() throws {
        assertMacroExpansion(
            """
            @RawUserDefaultValue(rawType: Int.self)
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
            @RawUserDefaultValue(rawType: Int.self)
            var value: ExampleEnum
            """,
            expandedSource: """
            var value: ExampleEnum
            """,
            diagnostics: [.init(message: UserDefaultValueError.defaultValueNeeded.description, line: 1, column: 1)],
            macros: testMacros
        )
    }
}
#endif
