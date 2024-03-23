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
