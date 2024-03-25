//
//  RawUserDefaultValue.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RawUserDefaultValue: AccessorMacro {

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
        guard let rawTypeParam = labeledExprListSyntax?.rawTypeParam, let variableType = VariableType(name: rawTypeParam) else {
            throw UserDefaultValueError.unsupportedType
        }

        let defaultValueParam = labeledExprListSyntax?.defaultValueParam
        guard typeAnnotation.isOptional || (!typeAnnotation.isOptional && defaultValueParam != nil) else {
            throw UserDefaultValueError.defaultValueNeeded
        }

        
        let defaultsParam = labeledExprListSyntax?.defaultsParam ?? .standardDefaults
        let keyParam = labeledExprListSyntax?.keyParam ?? identifierPatternSyntax.identifier.text.quoted
        let defaultValue = defaultValueParam.map { " ?? \($0)" } ?? ""
        
        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                "(\(raw: defaultsParam).object(forKey: \(raw: keyParam)) as? \(raw: variableType.nativeType)).flatMap(\(raw: typeAnnotation.orWrapped).init(rawValue:))\(raw: defaultValue)"
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                "\(raw: defaultsParam).\(raw: variableType.defaultsSetter)(newValue\(raw: typeAnnotation.isOptional ? "?" : "").rawValue, forKey: \(raw: keyParam))"
            },
        ]
    }
}
