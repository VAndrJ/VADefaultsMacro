//
//  UserDefaultValue.swift
//  
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct UserDefaultValue: AccessorMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclSyntax = declaration.as(VariableDeclSyntax.self),
              variableDeclSyntax.isVar,
              variableDeclSyntax.bindings.count == 1,
              let firstBinding = variableDeclSyntax.bindings.first,
              let identifierPatternSyntax = firstBinding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = firstBinding.typeAnnotation else {
            throw UserDefaultValueError.notVariable
        }

        let variableType = try getVariableType(typeSyntax: typeAnnotation.type)
        let labeledExprListSyntax = node.arguments?.as(LabeledExprListSyntax.self)
        let defaultValueExpr = labeledExprListSyntax?.defaultValueExpr
        if let defaultValueExpr,
           let literalType = LiteralExprType(expression: defaultValueExpr.expression),
           literalType.checkTypeMathing(variableType: variableType) == .doesNotMatch {
            throw UserDefaultValueError.typesMismatch
        }

        let defaultValueParam = labeledExprListSyntax?.defaultValueParam
        guard !variableType.isNilable || (variableType.isNilable && defaultValueParam != nil) else {
            throw UserDefaultValueError.defaultValueNeeded
        }

        let keyParam = labeledExprListSyntax?.keyParam ?? identifierPatternSyntax.identifier.text.quoted
        let defaultsParam = labeledExprListSyntax?.defaultsParam ?? .standardDefaults
        let defaultRegisteredValue = defaultValueParam.flatMap {
            variableType.isDefaultsNilable ? nil : "\(defaultsParam).register(defaults: [\(keyParam): \($0)])\n    return "
        } ?? ""
        let defaultValue = defaultValueParam.flatMap {
            variableType.isDefaultsNilable ? " ?? \($0)" : nil
        } ?? ""

        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                "\(raw: defaultRegisteredValue)\(raw: defaultsParam).\(raw: variableType.userDefaultsMethod)(forKey: \(raw: keyParam))\(raw: variableType.addingCastIfNeeded(defaultValue: defaultValueParam))\(raw: defaultValue)"
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                "\(raw: defaultsParam).\(raw: variableType.defaultsSetter)(newValue, forKey: \(raw: keyParam))"
            }
        ]
    }

    private static func getVariableType(typeSyntax: TypeSyntax?) throws -> VariableType {
        guard let typeSyntax else {
            throw UserDefaultValueError.notVariable
        }

        if let identifierTypeSyntax = typeSyntax.as(IdentifierTypeSyntax.self) {
            guard case let .identifier(typeName) = identifierTypeSyntax.name.tokenKind else {
                throw UserDefaultValueError.notVariable
            }
            guard let variableType = VariableType(name: typeName) else {
                throw UserDefaultValueError.unsupportedType
            }

            return variableType
        }

        if let optionalTypeSyntax = typeSyntax.as(OptionalTypeSyntax.self) {
            let wrappedType = try getVariableType(typeSyntax: optionalTypeSyntax.wrappedType)

            return .optional(wrapped: wrappedType)
        }

        if let arrayTypeSyntax = typeSyntax.as(ArrayTypeSyntax.self) {
            let elementTypeName = try getVariableType(typeSyntax: arrayTypeSyntax.element)

            return .array(element: elementTypeName)
        }

        if let dictionaryTypeSyntax = typeSyntax.as(DictionaryTypeSyntax.self) {
            let keyType = try getVariableType(typeSyntax: dictionaryTypeSyntax.key)
            guard keyType == .string else {
                throw UserDefaultValueError.dictKeyType
            }

            let valueType = try getVariableType(typeSyntax: dictionaryTypeSyntax.value)

            return .dictionary(key: keyType, value: valueType)
        }

        throw UserDefaultValueError.notVariable
    }
}

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
        case .array, .dictionary, .int8, .int16, .int32, .int64, .uInt8, .uInt16, .uInt32, .uInt64, .nsString, .nsNumber, .date, .nsDate, .nsData:
            return " as? \(nativeType)"
        case let .optional(wrappedType):
            if wrappedType.isNilable {
                return wrappedType.addingCastIfNeeded(defaultValue: defaultValue)
            }

            return " as? \(wrappedType.nativeType)"
        case .int, .bool, .uInt, .float, .double, .string, .url, .data:
            return ""
        }
    }
}

extension String {
    static let standardDefaults = "UserDefaults.standard"

    var quoted: String { "\"\(self)\"" }
    var asDefaults: String {
        if starts(with: ".") {
            return "UserDefaults\(self)"
        } else {
            return self
        }
    }
}

extension String? {
    var isEmpty: Bool { self?.isEmpty ?? true }
    var isNotEmpty: Bool { !isEmpty }
}

extension LabeledExprListSyntax {
    var defaultsParam: String? {
        guard let defaults = getLabeledExprSyntax("defaults") else {
            return nil
        }

        if let member = defaults.member {
            if member == "standard" {
                return nil
            } else {
                return member.asDefaults
            }
        } else if let decl = defaults.decl {
            return decl
        } else {
            return nil
        }
    }
    var keyParam: String? {
        guard let key = getLabeledExprSyntax("key") else {
            return nil
        }

        if let string = key.string {
            return string.quoted
        } else if let member = key.member {
            return member
        } else if let decl = key.decl {
            return decl
        } else {
            return nil
        }
    }
    var defaultValueExpr: LabeledExprSyntax? { getLabeledExprSyntax("defaultValue") }
    var defaultValueParam: String? { defaultValueExpr?.expression.trimmedDescription }

    private func getLabeledExprSyntax(_ text: String) -> LabeledExprSyntax? {
        first(where: { $0.label?.text == text })
    }
}

extension LabeledExprSyntax {
    var string: String? { self.expression.as(StringLiteralExprSyntax.self)?.segments.first?.trimmedDescription }
    var member: String? { self.expression.as(MemberAccessExprSyntax.self)?.trimmedDescription }
    var decl: String? { self.expression.as(DeclReferenceExprSyntax.self)?.trimmedDescription }
}

extension VariableDeclSyntax {
    public var isLet: Bool { bindingSpecifier.tokenKind == .keyword(.let) }
    public var isVar: Bool { bindingSpecifier.tokenKind == .keyword(.var) }
    public var isStatic: Bool { modifiers.contains { $0.name.tokenKind == .keyword(.static) } }
    public var isClass: Bool { modifiers.contains { $0.name.tokenKind == .keyword(.class) } }
    public var isInstance: Bool { !isClass && !isStatic }
}

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
