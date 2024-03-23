//
//  LiteralExprType.swift
//  
//
//  Created by Volodymyr Andriienko on 23.03.2024.
//

import SwiftSyntax

indirect enum LiteralExprType {
    enum VariableTypeMatching {
        case match
        case doesNotMatch
        case indeterminate
    }

    case string
    case boolean
    case integer
    case float

    init?(expression: ExprSyntax) {
        if expression.as(StringLiteralExprSyntax.self) != nil {
            self = .string
        } else if expression.as(BooleanLiteralExprSyntax.self) != nil {
            self = .boolean
        } else if expression.as(IntegerLiteralExprSyntax.self) != nil {
            self = .integer
        } else if expression.as(FloatLiteralExprSyntax.self) != nil {
            self = .float
        } else {
            return nil
        }
    }

    func checkTypeMathing(variableType: VariableType) -> VariableTypeMatching {
        switch self {
        case .string:
            switch variableType {
            case .string, .nsString: .match
            case let .optional(wrapped) where [.string, .nsString].contains(wrapped): .match
            case .bool, .int, .int8, .int16, .int32, .int64, .uInt, .uInt8, .uInt16, .uInt32, .uInt64, .float, .double, .nsNumber, .url, .date, .nsDate, .data, .nsData, .array, .dictionary, .optional: .doesNotMatch
            }
        case .boolean:
            switch variableType {
            case .bool: .match
            case let .optional(wrapped) where wrapped == .bool: .match
            case .string, .nsString, .int, .int8, .int16, .int32, .int64, .uInt, .uInt8, .uInt16, .uInt32, .uInt64, .float, .double, .nsNumber, .url, .date, .nsDate, .data, .nsData, .array, .dictionary, .optional: .doesNotMatch
            }
        case .integer:
            switch variableType {
            case .int, .int8, .int16, .int32, .int64, .uInt, .uInt8, .uInt16, .uInt32, .uInt64, .float, .double, .nsNumber: .match
            case let .optional(wrapped) where [.int, .int8, .int16, .int32, .int64, .uInt, .uInt8, .uInt16, .uInt32, .uInt64, .float, .double, .nsNumber].contains(wrapped): .match
            case .string, .nsString, .bool, .url, .date, .nsDate, .data, .nsData, .array, .dictionary, .optional: .doesNotMatch
            }
        case .float:
            switch variableType {
            case .float, .double: .match
            case let .optional(wrapped) where [.float, .double].contains(wrapped): .match
            case .bool, .string, .nsString, .int, .int8, .int16, .int32, .int64, .uInt, .uInt8, .uInt16, .uInt32, .uInt64, .url, .date, .nsDate, .data, .nsData, .array, .dictionary, .optional: .doesNotMatch
            case .nsNumber: .indeterminate
            }
        }
    }
}
