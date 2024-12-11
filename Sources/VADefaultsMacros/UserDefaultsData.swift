//
//  UserDefaultsData.swift
//
//
//  Created by Volodymyr Andriienko on 05.04.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct UserDefaultsData: MemberMacro, MemberAttributeMacro {
    public static let variableName = "userDefaults"
    public static let defaults = "UserDefaults"

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
        guard let variableDeclSyntax = member.as(VariableDeclSyntax.self),
              variableDeclSyntax.isVar,
              !(variableDeclSyntax.isStaticVariable || variableDeclSyntax.isClassVariable) else {
            return []
        }
        guard !variableDeclSyntax.attributes.isDefaultsValueMacro else {
            return []
        }
        guard variableDeclSyntax.bindings.count == 1,
            !variableDeclSyntax.bindings.contains(where: {
                $0.initializer != nil || $0.accessorBlock != nil
            }) else {
            return []
        }

        return [
            "@\(raw: String(describing: DefaultsValue.self))",
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let labeledExprListSyntax = node.arguments?.as(LabeledExprListSyntax.self)
        let defaults = labeledExprListSyntax?.defaultsParam ?? .standardDefaults
        let modifier: String
        if let initModifier = declaration.as(ClassDeclSyntax.self)?.modifiers.initModifier {
            modifier = initModifier
        } else if let initModifier = declaration.as(StructDeclSyntax.self)?.modifiers.initModifier {
            modifier = initModifier
        } else {
            throw UserDefaultsValueError.classOrStructNeeded
        }

        return [
            """
            private let \(raw: variableName): \(raw: UserDefaultsData.defaults)

            \(raw: modifier)init(\(raw: variableName): \(raw: UserDefaultsData.defaults) = \(raw: defaults)) {
                self.\(raw: variableName) = \(raw: variableName)
            }
            """
        ]
    }
}

extension DeclModifierListSyntax {
    var initModifier: String {
        switch first?.name.tokenKind {
        case let .keyword(keyword):
            switch keyword {
            case .public, .open: "public "
            case .fileprivate: "fileprivate "
            case .internal: "internal "
            default: ""
            }
        default: ""
        }
    }
}
