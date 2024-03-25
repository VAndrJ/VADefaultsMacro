//
//  UserDefaultValueError.swift
//  
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import Foundation

public enum UserDefaultValueError: Error, CustomStringConvertible {
    case notVariable
    case defaultValueNeeded
    case dictKeyType
    case unsupportedType
    case typesMismatch

    public var description: String {
        switch self {
        case .notVariable: "Must be `var` declaration."
        case .defaultValueNeeded: "This type requires a default value."
        case .dictKeyType: "The Dictionary key type must be `String`"
        case .unsupportedType: "Unsupported type"
        case .typesMismatch: "The type of the variable and the `defaultValue` must match"
        }
    }
}
