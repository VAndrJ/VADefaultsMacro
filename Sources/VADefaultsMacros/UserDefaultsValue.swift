//
//  UserDefaultsValue.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservationDefaultsTracked: PeerMacro {

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

public struct DefaultsValue: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try UserDefaultsValue.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context
        )
    }
}

public struct UserDefaultsValue: AccessorMacro {

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
            throw UserDefaultsValueError.notVariable
        }
        if !variableDeclSyntax.isStandaloneMacro && (variableDeclSyntax.isStaticVariable || variableDeclSyntax.isClassVariable) {
            throw UserDefaultsValueError.staticVariable
        }

        let variableType = try typeAnnotation.type.defaultsVariableType
        let labeledExprListSyntax = node.arguments?.as(LabeledExprListSyntax.self)
        let defaultValueExpr = labeledExprListSyntax?.defaultValueExpr
        if let defaultValueExpr,
           let literalType = LiteralExprType(expression: defaultValueExpr.expression),
           literalType.checkTypeMathing(variableType: variableType) == .doesNotMatch {
            throw UserDefaultsValueError.typesMismatch
        }

        let defaultValueParam = labeledExprListSyntax?.defaultValueParam
        guard !variableType.isNilable || (variableType.isNilable && defaultValueParam != nil) else {
            throw UserDefaultsValueError.defaultValueNeeded
        }

        let keyParam = labeledExprListSyntax?.keyParam ?? identifierPatternSyntax.identifier.text.quoted
        let defaultsParam = variableDeclSyntax.isStandaloneMacro ? (labeledExprListSyntax?.defaultsParam ?? .standardDefaults) : UserDefaultsData.variableName
        let isObservable = declaration.isObservable

        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                if isObservable {
                    "access(keyPath: \\.\(identifierPatternSyntax))"
                }
                if let defaultValueParam {
                    if variableType.isDefaultsNilable {
                        "\(raw: isObservable ? "return " : "")\(raw: defaultsParam).\(raw: variableType.userDefaultsMethod)(forKey: \(raw: keyParam))\(raw: variableType.addingCastIfNeeded(defaultValue: defaultValueParam)) ?? \(raw: defaultValueParam)"
                    } else  {
                        "\(raw: defaultsParam).register(defaults: [\(raw: keyParam): \(raw: defaultValueParam)])"
                        "return \(raw: defaultsParam).\(raw: variableType.userDefaultsMethod)(forKey: \(raw: keyParam))\(raw: variableType.addingCastIfNeeded(defaultValue: defaultValueParam))"
                    }
                } else {
                    "\(raw: isObservable ? "return " : "")\(raw: defaultsParam).\(raw: variableType.userDefaultsMethod)(forKey: \(raw: keyParam))\(raw: variableType.addingCastIfNeeded(defaultValue: defaultValueParam))"
                }
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                if isObservable {
                    """
                    withMutation(keyPath: \\.\(identifierPatternSyntax)) {
                        \(raw: defaultsParam).\(raw: variableType.defaultsSetter)(newValue, forKey: \(raw: keyParam))
                    }
                    """
                } else {
                    "\(raw: defaultsParam).\(raw: variableType.defaultsSetter)(newValue, forKey: \(raw: keyParam))"
                }
            },
        ]
    }
}
