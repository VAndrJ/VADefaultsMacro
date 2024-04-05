//
//  CodableUserDefaultValue.swift
//  
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodableDefaultValue: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try CodableUserDefaultValue.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context
        )
    }
}

public struct CodableUserDefaultValue: AccessorMacro {

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

        let labeledExprListSyntax = node.arguments?.as(LabeledExprListSyntax.self)
        let defaultValueParam = labeledExprListSyntax?.defaultValueParam
        if !typeAnnotation.isOptional && defaultValueParam == nil {
            throw UserDefaultValueError.defaultValueNeeded
        }

        let variableType = try typeAnnotation.type.codableVariableType
        let keyParam = labeledExprListSyntax?.keyParam ?? identifierPatternSyntax.identifier.text.quoted
        let defaultsParam = variableDeclSyntax.isStandaloneMacro ? (labeledExprListSyntax?.defaultsParam ?? .standardDefaults) : UserDefault.variableName
        let encoderParam = labeledExprListSyntax?.encoderParam ?? .encoder
        let decoderParam = labeledExprListSyntax?.decoderParam ?? .decoder
        let defaultValue = defaultValueParam.flatMap { " ?? \($0)" } ?? ""

        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                "\(raw: defaultsParam).data(forKey: \(raw: keyParam)).flatMap {try? \(raw: decoderParam).decode(\(raw: variableType).self, from: $0)}\(raw: defaultValue)"
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                "\(raw: defaultsParam).set(try? \(raw: encoderParam).encode(newValue), forKey: \(raw: keyParam))"
            },
        ]
    }
}
