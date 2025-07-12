//
//  VariableType.swift
//
//
//  Created by Volodymyr Andriienko on 23.03.2024.
//

import SwiftSyntax

indirect enum VariableType: Equatable {
    case bool
    case int
    case int8
    case int16
    case int32
    case int64
    case uInt
    case uInt8
    case uInt16
    case uInt32
    case uInt64
    case float
    case double
    case string
    case nsString
    case nsNumber
    case url
    case date
    case nsDate
    case data
    case nsData
    case array(element: VariableType)
    case dictionary(key: VariableType, value: VariableType)
    case optional(wrapped: VariableType)

    var defaultsSetter: String {
        switch self {
        case .url: "set"
        default: "setValue"
        }
    }
    var isDefaultsNilable: Bool {
        switch self {
        case .bool, .int, .float, .double: false
        default: true
        }
    }
    var isNilable: Bool {
        switch self {
        case .bool, .int, .float, .double, .optional: false
        default: true
        }
    }
    var nativeType: String {
        switch self {
        case .bool: "Bool"
        case .int: "Int"
        case .float: "Float"
        case .double: "Double"
        case .string: "String"
        case .url: "URL"
        case .data: "Data"
        case .int8: "Int8"
        case .int16: "Int16"
        case .int32: "Int32"
        case .int64: "Int64"
        case .uInt: "UInt"
        case .uInt8: "UInt8"
        case .uInt16: "UInt16"
        case .uInt32: "UInt32"
        case .uInt64: "UInt64"
        case .nsString: "NSString"
        case .nsNumber: "NSNumber"
        case .date: "Date"
        case .nsDate: "NSDate"
        case .nsData: "NSData"
        case let .array(element): "[\(element.nativeType)]"
        case let .dictionary(key, value): "[\(key.nativeType): \(value.nativeType)]"
        case let .optional(wrapped): "\(wrapped.nativeType)?"
        }
    }
    var userDefaultsMethod: String {
        switch self {
        case .bool: "bool"
        case .int: "integer"
        case .float: "float"
        case .double: "double"
        case .string: "string"
        case .url: "url"
        case .data: "data"
        case .array: "array"
        case .dictionary: "dictionary"
        case let .optional(wrapped) where wrapped.isNilable: wrapped.userDefaultsMethod
        case .optional, .nsData, .nsDate, .nsNumber, .nsString, .int8, .int16, .int32, .int64, .uInt, .uInt8, .uInt16, .uInt32, .uInt64, .date: "object"
        }
    }

    init?(name: String) {
        switch name {
        case "Bool": self = .bool
        case "Int": self = .int
        case "Float": self = .float
        case "Double": self = .double
        case "String": self = .string
        case "URL": self = .url
        case "Data": self = .data
        case "Int8": self = .int8
        case "Int16": self = .int16
        case "Int32": self = .int32
        case "Int64": self = .int64
        case "UInt": self = .uInt
        case "UInt8": self = .uInt8
        case "UInt16": self = .uInt16
        case "UInt32": self = .uInt32
        case "UInt64": self = .uInt64
        case "Date": self = .date
        case "NSString": self = .nsString
        case "NSNumber": self = .nsNumber
        case "NSDate": self = .nsDate
        case "NSData": self = .nsData
        default: return nil
        }
    }

    func addingCastIfNeeded(defaultValue: String?) -> String {
        switch self {
        case .array, .dictionary, .int8, .int16, .int32, .int64, .uInt8, .uInt16, .uInt32, .uInt64, .nsString, .nsNumber, .date, .nsDate, .nsData, .uInt:
            return " as? \(nativeType)"
        case let .optional(wrappedType):
            if wrappedType.isNilable {
                return wrappedType.addingCastIfNeeded(defaultValue: defaultValue)
            }

            return " as? \(wrappedType.nativeType)"
        case .int, .bool, .float, .double, .string, .url, .data:
            return ""
        }
    }
}
