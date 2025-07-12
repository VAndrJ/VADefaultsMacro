//
//  UserDefaultsValueError.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import Foundation

public enum UserDefaultsValueError: Error, CustomStringConvertible {
    case notVariable
    case defaultValueNeeded
    case dictKeyType
    case unsupportedType
    case typesMismatch
    case classOrStructNeeded
    case classNeeded
    case staticVariable

    public var description: String {
        switch self {
        case .notVariable: "Must be `var` declaration."
        case .defaultValueNeeded: "This type requires a default value."
        case .dictKeyType: "The Dictionary key type must be `String`."
        case .unsupportedType: "Unsupported type."
        case .typesMismatch: "The type of the variable and the `defaultValue` must match."
        case .classOrStructNeeded: "Must be a `class` or `struct`."
        case .classNeeded: "Must be a `class`."
        case .staticVariable: "Must not be a `static` variable declaration."
        }
    }
}
