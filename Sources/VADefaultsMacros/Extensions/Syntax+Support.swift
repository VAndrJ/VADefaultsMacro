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
            if member == ".standard" {
                return nil
            } else {
                return member.asDefaults
            }
        } else if let decl = defaults.decl {
            return decl
        } 

        return nil
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
        }

        return nil
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
        } 

        return nil
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
        }

        return nil
    }
    var rawTypeParam: String? {
        guard let rawType = getLabeledExprSyntax("rawType") else {
            return nil
        }

        if let member = rawType.memberBase {
            return member
        } 

        return nil
    }

    private func getLabeledExprSyntax(_ text: String) -> LabeledExprSyntax? {
        first(where: { $0.label?.text == text })
    }
}

extension VariableDeclSyntax {
    var isStandaloneMacro: Bool { attributes.isStandaloneMacro }
}

extension AttributeListSyntax {
    var isStandaloneMacro: Bool {
        contains(type: UserDefaultsValue.self) ||
        contains(type: RawUserDefaultsValue.self) ||
        contains(type: CodableUserDefaultsValue.self)
    }
    var isDefaultsValueMacro: Bool {
        contains(type: UserDefaultsValue.self) ||
        contains(type: RawUserDefaultsValue.self) ||
        contains(type: CodableUserDefaultsValue.self) ||
        contains(type: DefaultsValue.self) ||
        contains(type: RawDefaultsValue.self) ||
        contains(type: CodableDefaultsValue.self)
    }

    private func contains<T>(type: T.Type) -> Bool {
        contains(where: { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == String(describing: type) })
    }
}

extension LabeledExprSyntax {
    var string: String? { self.expression.as(StringLiteralExprSyntax.self)?.segments.first?.trimmedDescription }
    var memberExpr: MemberAccessExprSyntax? { self.expression.as(MemberAccessExprSyntax.self) }
    var member: String? { memberExpr?.trimmedDescription }
    var memberBase: String? { memberExpr?.base?.trimmedDescription }
    var decl: String? { self.expression.as(DeclReferenceExprSyntax.self)?.trimmedDescription }
    var function: String? { self.expression.as(FunctionCallExprSyntax.self)?.trimmedDescription }
}

private let varKeyowrd: TokenKind = .keyword(.var)
private let staticKeyowrd: TokenKind = .keyword(.static)
private let classKeyowrd: TokenKind = .keyword(.class)

extension VariableDeclSyntax {
    public var isVar: Bool { bindingSpecifier.tokenKind == varKeyowrd }
    public var isStaticVariable: Bool { modifiers.contains { $0.name.tokenKind == staticKeyowrd } }
    public var isClassVariable: Bool { modifiers.contains { $0.name.tokenKind == classKeyowrd } }
}

extension TypeSyntax {
    var isOptional: Bool { self.is(OptionalTypeSyntax.self) }
    var codableVariableType: String {
        get throws {
            if let identifierTypeSyntax = self.as(IdentifierTypeSyntax.self) {
                guard case let .identifier(typeName) = identifierTypeSyntax.name.tokenKind else {
                    throw UserDefaultsValueError.notVariable
                }

                return typeName
            }

            if let optionalTypeSyntax = self.as(OptionalTypeSyntax.self) {
                let wrappedType = try optionalTypeSyntax.wrappedType.codableVariableType

                return wrappedType
            }

            throw UserDefaultsValueError.notVariable
        }
    }
    var defaultsVariableType: VariableType {
        get throws {
            if let identifierTypeSyntax = self.as(IdentifierTypeSyntax.self) {
                guard case let .identifier(typeName) = identifierTypeSyntax.name.tokenKind else {
                    throw UserDefaultsValueError.notVariable
                }
                guard let variableType = VariableType(name: typeName) else {
                    throw UserDefaultsValueError.unsupportedType
                }

                return variableType
            }

            if let optionalTypeSyntax = self.as(OptionalTypeSyntax.self) {
                let wrappedType = try optionalTypeSyntax.wrappedType.defaultsVariableType

                return .optional(wrapped: wrappedType)
            }

            if let arrayTypeSyntax = self.as(ArrayTypeSyntax.self) {
                let elementTypeName = try arrayTypeSyntax.element.defaultsVariableType

                return .array(element: elementTypeName)
            }

            if let dictionaryTypeSyntax = self.as(DictionaryTypeSyntax.self) {
                let keyType = try dictionaryTypeSyntax.key.defaultsVariableType
                guard keyType == .string else {
                    throw UserDefaultsValueError.dictKeyType
                }

                let valueType = try dictionaryTypeSyntax.value.defaultsVariableType

                return .dictionary(key: keyType, value: valueType)
            }

            throw UserDefaultsValueError.notVariable
        }
    }
}

extension TypeAnnotationSyntax {
    var isOptional: Bool { type.isOptional }
    var orWrapped: String {
        if let optionalTypeSyntax = type.as(OptionalTypeSyntax.self) {
            optionalTypeSyntax.wrappedType.trimmedDescription
        } else {
            type.trimmedDescription
        }
    }
}
