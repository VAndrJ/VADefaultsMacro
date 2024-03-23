//
//  Syntax+Support.swift
//
//
//  Created by Volodymyr Andriienko on 22.03.2024.
//

import SwiftSyntax

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
    var encoderParam: String? {
        guard let encoder = getLabeledExprSyntax("encoder") else {
            return nil
        }

        if let member = encoder.member {
            return member.asEncoder
        } else if let decl = encoder.decl {
            return decl
        } else if let function = encoder.function {
            return function.asEncoder
        } else {
            return nil
        }
    }
    var decoderParam: String? {
        guard let decoder = getLabeledExprSyntax("decoder") else {
            return nil
        }

        if let member = decoder.member {
            return member.asDecoder
        } else if let decl = decoder.decl {
            return decl
        } else if let function = decoder.function {
            return function.asDecoder
        } else {
            return nil
        }
    }

    private func getLabeledExprSyntax(_ text: String) -> LabeledExprSyntax? {
        first(where: { $0.label?.text == text })
    }
}

extension LabeledExprSyntax {
    var string: String? { self.expression.as(StringLiteralExprSyntax.self)?.segments.first?.trimmedDescription }
    var member: String? { self.expression.as(MemberAccessExprSyntax.self)?.trimmedDescription }
    var decl: String? { self.expression.as(DeclReferenceExprSyntax.self)?.trimmedDescription }
    var function: String? { self.expression.as(FunctionCallExprSyntax.self)?.trimmedDescription }
}

extension VariableDeclSyntax {
    public var isLet: Bool { bindingSpecifier.tokenKind == .keyword(.let) }
    public var isVar: Bool { bindingSpecifier.tokenKind == .keyword(.var) }
    public var isStatic: Bool { modifiers.contains { $0.name.tokenKind == .keyword(.static) } }
    public var isClass: Bool { modifiers.contains { $0.name.tokenKind == .keyword(.class) } }
    public var isInstance: Bool { !isClass && !isStatic }
}

extension TypeSyntax {
    var isOptional: Bool { self.as(OptionalTypeSyntax.self) != nil }
}

extension TypeAnnotationSyntax {
    var isOptional: Bool { self.type.isOptional }
}
