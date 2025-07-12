//
//  RawUserDefaultsValue.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RawDefaultsValue: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try RawUserDefaultsValue.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context
        )
    }
}

public struct RawUserDefaultsValue: AccessorMacro {

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
            let typeAnnotation = firstBinding.typeAnnotation
        else {
            throw UserDefaultsValueError.notVariable
        }
        if !(variableDeclSyntax.isStandaloneMacro || variableDeclSyntax.isInstance) {
            throw UserDefaultsValueError.staticVariable
        }

        let labeledExprListSyntax = node.arguments?.as(LabeledExprListSyntax.self)
        guard let rawTypeParam = labeledExprListSyntax?.rawTypeParam, let variableType = VariableType(name: rawTypeParam) else {
            throw UserDefaultsValueError.unsupportedType
        }

        let defaultValueParam = labeledExprListSyntax?.defaultValueParam
        guard typeAnnotation.isOptional || (!typeAnnotation.isOptional && defaultValueParam != nil) else {
            throw UserDefaultsValueError.defaultValueNeeded
        }

        let keyPrefix = variableDeclSyntax.isStandaloneMacro ? "" : context.prefix
        let keyParam = labeledExprListSyntax?.keyParam ?? "\(keyPrefix)\(identifierPatternSyntax.identifier.text)".quoted
        let defaultValue = defaultValueParam.map { " ?? \($0)" } ?? ""
        let defaultsParam = variableDeclSyntax.isStandaloneMacro ? (labeledExprListSyntax?.defaultsParam ?? .standardDefaults) : UserDefaultsData.variableName
        let isObservable = context.isObservable

        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                if isObservable {
                    "access(keyPath: \\.\(identifierPatternSyntax))"
                }
                "\(raw: isObservable ? "return " : "")(\(raw: defaultsParam).object(forKey: \(raw: keyParam)) as? \(raw: variableType.nativeType)).flatMap(\(raw: typeAnnotation.orWrapped).init(rawValue:))\(raw: defaultValue)"
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                if isObservable {
                    """
                    withMutation(keyPath: \\.\(identifierPatternSyntax)) {
                        \(raw: defaultsParam).\(raw: variableType.defaultsSetter)(newValue\(raw: typeAnnotation.isOptional ? "?" : "").rawValue, forKey: \(raw: keyParam))
                    }
                    """
                } else {
                    "\(raw: defaultsParam).\(raw: variableType.defaultsSetter)(newValue\(raw: typeAnnotation.isOptional ? "?" : "").rawValue, forKey: \(raw: keyParam))"
                }
            },
        ]
    }
}
