//
//  CodableUserDefaultsValue.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodableDefaultsValue: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try CodableUserDefaultsValue.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context
        )
    }
}

public struct CodableUserDefaultsValue: AccessorMacro {

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
        let defaultValueParam = labeledExprListSyntax?.defaultValueParam
        if !typeAnnotation.isOptional && defaultValueParam == nil {
            throw UserDefaultsValueError.defaultValueNeeded
        }

        let variableType = try typeAnnotation.type.codableVariableType
        let keyPrefix = variableDeclSyntax.isStandaloneMacro ? "" : context.prefix
        let keyParam = labeledExprListSyntax?.keyParam ?? "\(keyPrefix)\(identifierPatternSyntax.identifier.text)".quoted
        let encoderParam = labeledExprListSyntax?.encoderParam ?? .encoder
        let decoderParam = labeledExprListSyntax?.decoderParam ?? .decoder
        let defaultValue = defaultValueParam.flatMap { " ?? \($0)" } ?? ""
        let defaultsParam = variableDeclSyntax.isStandaloneMacro ? (labeledExprListSyntax?.defaultsParam ?? .standardDefaults) : UserDefaultsData.variableName
        let isObservable = context.isObservable

        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                if isObservable {
                    "access(keyPath: \\.\(identifierPatternSyntax))"
                }
                "\(raw: isObservable ? "return " : "")\(raw: defaultsParam).data(forKey: \(raw: keyParam)).flatMap {try? \(raw: decoderParam).decode(\(raw: variableType).self, from: $0)}\(raw: defaultValue)"
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                if isObservable {
                    """
                    withMutation(keyPath: \\.\(identifierPatternSyntax)) {
                        \(raw: defaultsParam).set(try? \(raw: encoderParam).encode(newValue), forKey: \(raw: keyParam))
                    }
                    """
                } else {
                    "\(raw: defaultsParam).set(try? \(raw: encoderParam).encode(newValue), forKey: \(raw: keyParam))"
                }
            },
        ]
    }
}
