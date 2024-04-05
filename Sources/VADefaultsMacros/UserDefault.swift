//
//  UserDefault.swift
//
//
//  Created by Volodymyr Andriienko on 05.04.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct UserDefault: MemberMacro, MemberAttributeMacro {
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
              !variableDeclSyntax.isStatic,
              !variableDeclSyntax.attributes.isDefaultValueMacro,
              variableDeclSyntax.bindings.count == 1,
              !variableDeclSyntax.bindings.contains(where: {
                  $0.initializer != nil || $0.accessorBlock != nil
              }) else {
            return []
        }

        return ["@\(raw: String(describing: DefaultValue.self))"]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
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
            throw UserDefaultValueError.classOfStructNeeded
        }
        
        return [
            """
            private let \(raw: variableName): \(raw: self.defaults)

            \(raw: modifier)init(\(raw: variableName): \(raw: self.defaults) = \(raw: defaults)) {
                self.\(raw: variableName) = \(raw: variableName)
            }
            """,
        ]
    }
}

private extension DeclModifierListSyntax {
    var initModifier: String {
        switch first?.as(DeclModifierSyntax.self)?.name.tokenKind {
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
